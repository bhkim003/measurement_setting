#!/usr/bin/env python3
"""
run_lm_eval_benchmark.py
========================
lm_eval(Language Model Evaluation Harness)을 Python 코드로 직접 실행하는 스크립트입니다.
CLI가 아닌 Python API를 사용하여 더 세밀한 제어가 가능합니다.

★ lm_eval이란?
  EleutherAI에서 만든 LLM 벤치마크 도구입니다.
  다양한 NLP 태스크로 모델의 성능을 측정할 수 있습니다.
  논문에서 "우리 모델은 HellaSwag에서 XX% 달성" 이런 결과가 이 도구로 측정됩니다.

★ 사용법:
    python run_lm_eval_benchmark.py --model_name meta-llama/Llama-3.2-1B

★ 사전 준비:
    pip install torch transformers accelerate lm-eval sentencepiece protobuf
"""

import argparse
import json
import os
from datetime import datetime

# ═══════════════════════════════════════════════════════════════════════════════
# ★★★ lm_eval에서 자주 사용하는 태스크 상세 설명 ★★★
# ═══════════════════════════════════════════════════════════════════════════════
#
# 아래는 lm_eval에서 LLM을 평가할 때 흔히 사용하는 벤치마크 태스크들입니다.
# 각 태스크가 무엇을 측정하는지 한글로 설명합니다.
#
# ─────────────────────────────────────────────────────────────────────────────
# 1. hellaswag (HellaSwag)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "상식 추론" (Commonsense Reasoning)
#    • 형식: 문장의 시작이 주어지고, 가장 자연스러운 이어지는 문장을 4개 중 고르기
#    • 예시:
#      "남자가 수영장에 다이빙했다. 그 다음에..."
#      (A) 물속에서 수영을 시작했다  ← 정답
#      (B) 비행기를 타고 날아갔다
#      (C) 책을 읽기 시작했다
#      (D) 산을 올라갔다
#    • 메트릭: accuracy (정확도)
#    • 난이도: 중간 — 사람은 95%+, GPT-4는 95%+, 작은 모델은 40~70%
#
# ─────────────────────────────────────────────────────────────────────────────
# 2. arc_easy (ARC-Easy)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "과학 상식" (Science Questions)
#    • 형식: 초등학교~중학교 수준의 과학 객관식 문제 (4지선다)
#    • 출처: AI2 Reasoning Challenge (ARC) 데이터셋의 쉬운 파트
#    • 예시:
#      "식물이 광합성을 하려면 무엇이 필요한가?"
#      (A) 빛  ← 정답  (B) 돌  (C) 금속  (D) 소금
#    • 메트릭: accuracy (정확도), acc_norm (정규화 정확도)
#
# ─────────────────────────────────────────────────────────────────────────────
# 3. arc_challenge (ARC-Challenge)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "어려운 과학 추론"
#    • arc_easy와 같은 데이터셋이지만 더 어려운 문제만 모은 것
#    • 단순 통계적 방법으로는 풀기 어려운 문제들
#    • 메트릭: accuracy, acc_norm
#
# ─────────────────────────────────────────────────────────────────────────────
# 4. winogrande (WinoGrande)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "대명사 해석 / 상식 추론" (Coreference Resolution)
#    • 형식: 문장에서 빈칸(_)에 들어갈 단어를 2개 중 고르기
#    • 예시:
#      "트로피가 가방에 안 들어갔다. _이(가) 너무 컸기 때문이다."
#      (A) 트로피  ← 정답  (B) 가방
#    • 메트릭: accuracy
#    • 특징: 문맥을 정확히 이해해야 풀 수 있음
#
# ─────────────────────────────────────────────────────────────────────────────
# 5. piqa (PIQA - Physical Intuition QA)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "물리적 상식" (Physical Commonsense)
#    • 형식: 물리적 상황에 대한 2지선다 문제
#    • 예시:
#      "컵에 물을 넣으려면?"
#      (A) 수도꼭지 아래에 컵을 놓고 물을 틀어라  ← 정답
#      (B) 컵을 거꾸로 놓고 물을 부어라
#    • 메트릭: accuracy
#
# ─────────────────────────────────────────────────────────────────────────────
# 6. boolq (BoolQ)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "예/아니오 질의응답" (Boolean Question Answering)
#    • 형식: 지문(passage)과 질문이 주어지고, 예(True) 또는 아니오(False)로 답
#    • 예시:
#      지문: "서울은 대한민국의 수도이다."
#      질문: "서울은 일본의 수도인가?"
#      답: False
#    • 메트릭: accuracy
#
# ─────────────────────────────────────────────────────────────────────────────
# 7. openbookqa (OpenBookQA)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "과학 상식 + 추론"
#    • 형식: 핵심 과학 사실이 주어지고, 이를 응용하는 4지선다 문제
#    • 오픈북 시험처럼 기본 지식은 주어지지만 응용력이 필요
#    • 메트릭: accuracy, acc_norm
#
# ─────────────────────────────────────────────────────────────────────────────
# 8. mmlu (Massive Multitask Language Understanding)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "광범위한 지식" (57개 분야)
#    • 형식: 57개 주제(수학, 역사, 법률, 의학, CS 등)의 4지선다 문제
#    • 가장 널리 사용되는 LLM 벤치마크 중 하나
#    • 주의: 문제 수가 많아서 실행 시간이 오래 걸림
#    • 메트릭: accuracy
#
# ─────────────────────────────────────────────────────────────────────────────
# 9. truthfulqa_mc2 (TruthfulQA)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "진실된 답변 능력"
#    • 형식: 사람들이 흔히 오해하는 질문에 정확하게 답하는지 평가
#    • 예시: "만리장성은 우주에서 보이나요?" → 정답: "아니오"
#    • 모델이 잘못된 통념을 따라가지 않는지 확인
#    • 메트릭: accuracy (mc2 = multiple choice 2)
#
# ─────────────────────────────────────────────────────────────────────────────
# 10. gsm8k (Grade School Math 8K)
# ─────────────────────────────────────────────────────────────────────────────
#    • 무엇을 측정? → "수학적 추론" (Math Reasoning)
#    • 형식: 초등학교 수준 수학 서술형 문제를 단계별로 풀기
#    • 예시: "사과가 5개 있고, 3개를 더 사면 총 몇 개?"
#    • 메트릭: exact_match (정답과 정확히 일치하는지)
#    • 특징: chain-of-thought 추론 능력을 봄
#
# ═══════════════════════════════════════════════════════════════════════════════
# ★ 태스크 선택 가이드 ★
# ═══════════════════════════════════════════════════════════════════════════════
#
# 빠르게 테스트하고 싶을 때:
#   → hellaswag, arc_easy, piqa (비교적 빠름)
#
# 종합적인 평가를 하고 싶을 때:
#   → hellaswag, arc_easy, arc_challenge, winogrande, piqa, boolq, mmlu
#
# 특정 능력을 평가하고 싶을 때:
#   → 상식 추론: hellaswag, winogrande, piqa
#   → 지식: mmlu, arc_easy, arc_challenge
#   → 독해: boolq
#   → 수학: gsm8k
#   → 신뢰성: truthfulqa_mc2
#
# ═══════════════════════════════════════════════════════════════════════════════


def run_evaluation(model_name: str, tasks: list, device: str, batch_size: str,
                   output_dir: str, num_fewshot: int = 0,
                   dtype: str = "float16") -> dict:
    """
    lm_eval Python API를 사용하여 벤치마크를 실행합니다.

    Parameters
    ----------
    model_name : str
        Hugging Face 모델 이름 (예: "meta-llama/Llama-3.2-1B")
    tasks : list
        실행할 태스크 이름 목록 (예: ["hellaswag", "arc_easy"])
    device : str
        사용할 디바이스 (예: "cuda:0", "cpu")
    batch_size : str
        배치 크기 (예: "auto", "8", "16")
    output_dir : str
        결과 저장 경로
    num_fewshot : int
        few-shot 예제 수 (0 = zero-shot)
    dtype : str
        모델 가중치 정밀도 (float16, bfloat16, float32)

    Returns
    -------
    dict
        평가 결과 딕셔너리
    """
    # ── lm_eval 임포트 ──
    # simple_evaluate: 가장 간단하게 평가를 실행하는 함수
    import lm_eval

    print("\n" + "=" * 70)
    print("  lm_eval 벤치마크 실행")
    print("=" * 70)
    print(f"  모델      : {model_name}")
    print(f"  태스크    : {tasks}")
    print(f"  디바이스  : {device}")
    print(f"  배치 크기 : {batch_size}")
    print(f"  few-shot  : {num_fewshot}")
    print("=" * 70 + "\n")

    # ── 평가 실행 ──
    # simple_evaluate()는 lm_eval의 핵심 함수입니다.
    # 내부적으로 다음 과정이 진행됩니다:
    #   1) 모델 로드 (HuggingFace Transformers 사용)
    #   2) 태스크 데이터셋 다운로드
    #   3) 각 태스크의 프롬프트를 모델에 입력
    #   4) 모델의 출력(로짓)으로 정답 여부 판정
    #   5) 결과 집계
    results = lm_eval.simple_evaluate(
        model="hf",                          # Hugging Face 모델 사용
        model_args=f"pretrained={model_name},"
                   f"dtype={dtype}",          # 정밀도 설정 (float16, bfloat16, float32)
        tasks=tasks,                          # 실행할 태스크 목록
        device=device,                        # GPU/CPU 지정
        batch_size=batch_size,                # 배치 크기
        num_fewshot=num_fewshot,              # few-shot 예제 수
        log_samples=True,                     # 각 샘플의 상세 로그 저장
    )

    # ── 결과 출력 ──
    print("\n" + "=" * 70)
    print("  ★ 평가 결과 ★")
    print("=" * 70)

    # results["results"]에 태스크별 결과가 들어있습니다
    for task_name, task_result in results["results"].items():
        print(f"\n  📊 {task_name}:")
        for metric_name, value in task_result.items():
            # 'alias' 같은 메타데이터는 건너뛰기
            if isinstance(value, (int, float)):
                # 0~1 범위의 메트릭만 퍼센트로 변환하여 표시
                if 0 <= value <= 1:
                    print(f"     {metric_name}: {value:.4f} ({value * 100:.2f}%)")
                else:
                    print(f"     {metric_name}: {value:.4f}")
            else:
                print(f"     {metric_name}: {value}")

    # ── 결과 저장 ──
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = os.path.join(output_dir, f"results_{timestamp}.json")

        # results 객체에서 저장 가능한 부분만 추출
        save_data = {
            "model": model_name,
            "tasks": tasks,
            "num_fewshot": num_fewshot,
            "results": results.get("results", {}),
            "config": {
                "device": device,
                "batch_size": batch_size,
            },
        }

        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(save_data, f, indent=2, ensure_ascii=False, default=str)
        print(f"\n  💾 결과가 {output_file} 에 저장되었습니다.")

    return results


def main():
    parser = argparse.ArgumentParser(
        description="Llama 3.2 1B lm_eval 벤치마크 실행 스크립트"
    )
    parser.add_argument(
        "--model_name",
        type=str,
        default="meta-llama/Llama-3.2-1B",
        help="Hugging Face 모델 이름 (기본값: meta-llama/Llama-3.2-1B)",
    )
    parser.add_argument(
        "--tasks",
        type=str,
        default="hellaswag,arc_easy,winogrande,piqa,boolq",
        help="실행할 태스크 목록 (쉼표 구분, 기본값: hellaswag,arc_easy,winogrande,piqa,boolq)",
    )
    parser.add_argument(
        "--device",
        type=str,
        default="cuda:0",
        help="사용할 디바이스 (기본값: cuda:0, GPU 없으면 cpu로 변경)",
    )
    parser.add_argument(
        "--batch_size",
        type=str,
        default="auto",
        help="배치 크기 (기본값: auto)",
    )
    parser.add_argument(
        "--output_dir",
        type=str,
        default="./lm_eval_results",
        help="결과 저장 디렉토리 (기본값: ./lm_eval_results)",
    )
    parser.add_argument(
        "--num_fewshot",
        type=int,
        default=0,
        help="few-shot 예제 수 (기본값: 0 = zero-shot)",
    )
    parser.add_argument(
        "--dtype",
        type=str,
        default="float16",
        help="모델 가중치 정밀도 (기본값: float16, 선택: float16, bfloat16, float32)",
    )
    args = parser.parse_args()

    # 태스크 문자열을 리스트로 변환
    tasks = [t.strip() for t in args.tasks.split(",")]

    # ── 태스크 목록 출력 ──
    print("\n" + "█" * 70)
    print("  Llama 3.2 1B — lm_eval 벤치마크")
    print("█" * 70)
    print("\n실행할 태스크 목록:")
    for i, task in enumerate(tasks, 1):
        print(f"  {i}. {task}")

    # ── 평가 실행 ──
    run_evaluation(
        model_name=args.model_name,
        tasks=tasks,
        device=args.device,
        batch_size=args.batch_size,
        output_dir=args.output_dir,
        num_fewshot=args.num_fewshot,
        dtype=args.dtype,
    )

    print("\n" + "=" * 70)
    print("  ✅ 모든 평가가 완료되었습니다!")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
