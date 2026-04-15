#!/usr/bin/env python3
"""
inspect_model.py
================
Llama 3.2 1B 모델을 불러와서 내부 구조(아키텍처)를 상세하게 출력하는 스크립트입니다.
각 모듈(레이어)이 어떤 역할을 하는지 한글 주석으로 설명합니다.

★ 사용법:
    python inspect_model.py --model_name meta-llama/Llama-3.2-1B

★ 사전 준비:
    pip install torch transformers accelerate sentencepiece protobuf
    huggingface-cli login   # Llama는 gated model이므로 토큰 필요
"""

import argparse
import sys

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, AutoConfig


def print_separator(title: str) -> None:
    """구분선 출력 헬퍼"""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def inspect_config(model_name: str) -> None:
    """
    ─────────────────────────────────────────────────
    [STEP 1] 모델 설정(Config) 정보 출력
    ─────────────────────────────────────────────────
    모델을 다운로드하지 않고도 config만 먼저 확인할 수 있습니다.
    config에는 모델의 하이퍼파라미터가 들어있습니다.
    """
    print_separator("STEP 1: 모델 설정(Config) 확인")

    config = AutoConfig.from_pretrained(model_name)
    print(f"\n모델 이름       : {model_name}")
    print(f"모델 타입       : {config.model_type}")

    # ── 주요 하이퍼파라미터 설명 ──
    params = {
        "hidden_size (은닉 차원)": getattr(config, "hidden_size", "N/A"),
        "num_hidden_layers (트랜스포머 블록 수)": getattr(config, "num_hidden_layers", "N/A"),
        "num_attention_heads (어텐션 헤드 수)": getattr(config, "num_attention_heads", "N/A"),
        "num_key_value_heads (KV 헤드 수, GQA용)": getattr(config, "num_key_value_heads", "N/A"),
        "intermediate_size (FFN 중간 차원)": getattr(config, "intermediate_size", "N/A"),
        "vocab_size (어휘 크기)": getattr(config, "vocab_size", "N/A"),
        "max_position_embeddings (최대 시퀀스 길이)": getattr(config, "max_position_embeddings", "N/A"),
        "rms_norm_eps (RMSNorm 엡실론)": getattr(config, "rms_norm_eps", "N/A"),
        "rope_theta (RoPE 베이스 주파수)": getattr(config, "rope_theta", "N/A"),
        "torch_dtype (모델 가중치 dtype)": str(getattr(config, "torch_dtype", "N/A")),
    }

    print("\n[ 주요 하이퍼파라미터 ]")
    for name, value in params.items():
        print(f"  • {name}: {value}")

    # 각 파라미터 설명
    print("\n[ 파라미터 설명 ]")
    explanations = [
        ("hidden_size", "모델 내부에서 토큰을 표현하는 벡터의 차원. 클수록 표현력이 높지만 메모리/연산 증가."),
        ("num_hidden_layers", "트랜스포머 디코더 블록이 몇 층 쌓여있는지. Llama 3.2 1B는 약 16층."),
        ("num_attention_heads", "멀티헤드 어텐션에서 쿼리(Q)를 몇 개의 헤드로 나누는지."),
        ("num_key_value_heads", "GQA(Grouped Query Attention)에서 Key/Value 헤드 수. Q 헤드보다 적으면 메모리 절약."),
        ("intermediate_size", "FFN(Feed-Forward Network)의 중간 레이어 차원. 보통 hidden_size의 2~4배."),
        ("vocab_size", "토크나이저가 다루는 전체 토큰(단어 조각) 개수."),
        ("max_position_embeddings", "모델이 처리할 수 있는 최대 입력 길이(토큰 수)."),
        ("rms_norm_eps", "RMSNorm에서 0으로 나누는 것을 방지하기 위한 아주 작은 값."),
        ("rope_theta", "RoPE(Rotary Position Embedding)의 주파수 스케일링 기준값."),
    ]
    for name, desc in explanations:
        print(f"  • {name}: {desc}")


def inspect_model_architecture(model_name: str) -> None:
    """
    ─────────────────────────────────────────────────
    [STEP 2] 모델 로드 및 전체 아키텍처 출력
    ─────────────────────────────────────────────────
    실제로 모델 가중치를 다운로드하고 로드합니다.
    """
    print_separator("STEP 2: 모델 아키텍처 전체 출력")

    print("\n모델 로딩 중... (처음이면 다운로드에 시간이 걸립니다)")
    print("※ Llama 3.2는 gated model입니다. HF 토큰이 필요합니다.\n")

    # ── 모델 로딩 ──
    # torch_dtype=torch.float16  : 메모리 절약을 위해 FP16으로 로드
    # device_map="auto"          : 사용 가능한 GPU에 자동 배치
    #                              GPU가 없으면 CPU로 폴백
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16,   # 16비트 부동소수점으로 메모리 절약
        device_map="auto",           # GPU 자동 배치 (없으면 CPU)
    )

    # ── 전체 모델 구조 출력 ──
    print("\n" + "-" * 70)
    print("  전체 모델 구조 (print(model))")
    print("-" * 70)
    print(model)

    # ── 파라미터 수 계산 ──
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"\n총 파라미터 수     : {total_params:,} ({total_params / 1e9:.2f}B)")
    print(f"학습 가능 파라미터 : {trainable_params:,}")

    return model


def explain_modules() -> None:
    """
    ─────────────────────────────────────────────────
    [STEP 3] Llama 모델의 각 모듈(레이어) 역할 설명
    ─────────────────────────────────────────────────
    Llama 3.2 1B의 내부 구조를 한글로 상세히 설명합니다.
    """
    print_separator("STEP 3: Llama 3.2 모델 내부 모듈 상세 설명")

    explanations = """
┌─────────────────────────────────────────────────────────────────────┐
│                    LlamaForCausalLM (최상위)                         │
│  - Llama 모델 + 언어모델 헤드(lm_head)를 합친 것                      │
│  - "Causal LM" = 왼쪽→오른쪽으로만 보는 자기회귀 언어모델               │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ model (LlamaModel) — 트랜스포머 디코더 본체                     │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │ embed_tokens (nn.Embedding)                             │  │  │
│  │  │  - 토큰 ID → 벡터 변환 (입력 임베딩)                      │  │  │
│  │  │  - shape: (vocab_size, hidden_size)                     │  │  │
│  │  │  - 예: 토큰 ID 1234 → [0.12, -0.34, ...] 벡터          │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │ layers (ModuleList) — 트랜스포머 디코더 블록 × N층         │  │  │
│  │  │                                                         │  │  │
│  │  │  각 층(LlamaDecoderLayer)의 구성:                        │  │  │
│  │  │                                                         │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │ input_layernorm (LlamaRMSNorm)                   │  │  │  │
│  │  │  │  - 어텐션 전에 입력을 정규화                         │  │  │  │
│  │  │  │  - RMSNorm: LayerNorm의 경량 버전                  │  │  │  │
│  │  │  │  - 평균을 빼지 않고, RMS(제곱평균제곱근)만 사용       │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                         │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │ self_attn (LlamaSdpaAttention)                    │  │  │  │
│  │  │  │  - 셀프 어텐션: "이 토큰이 다른 토큰들과 얼마나       │  │  │  │
│  │  │  │    관련 있는지"를 계산                               │  │  │  │
│  │  │  │                                                   │  │  │  │
│  │  │  │  • q_proj (Linear): 쿼리(Q) 프로젝션               │  │  │  │
│  │  │  │    → "나는 무엇을 찾고 있는가?"                      │  │  │  │
│  │  │  │  • k_proj (Linear): 키(K) 프로젝션                  │  │  │  │
│  │  │  │    → "내가 가진 정보의 라벨"                         │  │  │  │
│  │  │  │  • v_proj (Linear): 밸류(V) 프로젝션                │  │  │  │
│  │  │  │    → "실제 전달할 정보"                              │  │  │  │
│  │  │  │  • o_proj (Linear): 출력 프로젝션                   │  │  │  │
│  │  │  │    → 멀티헤드 결과를 합쳐서 원래 차원으로 변환         │  │  │  │
│  │  │  │                                                   │  │  │  │
│  │  │  │  ※ Llama 3.2는 GQA(Grouped Query Attention) 사용  │  │  │  │
│  │  │  │    → K, V 헤드 수 < Q 헤드 수 → 메모리 절약          │  │  │  │
│  │  │  │  ※ RoPE(Rotary Position Embedding) 적용            │  │  │  │
│  │  │  │    → 위치 정보를 회전 행렬로 인코딩                   │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                         │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │ post_attention_layernorm (LlamaRMSNorm)          │  │  │  │
│  │  │  │  - FFN 전에 어텐션 출력을 정규화                     │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                         │  │  │
│  │  │  ┌───────────────────────────────────────────────────┐  │  │  │
│  │  │  │ mlp (LlamaMLP) — Feed-Forward Network             │  │  │  │
│  │  │  │  - 각 토큰 위치에 독립적으로 적용되는 비선형 변환      │  │  │  │
│  │  │  │                                                   │  │  │  │
│  │  │  │  • gate_proj (Linear): 게이트 프로젝션              │  │  │  │
│  │  │  │    → SwiGLU 활성화 함수의 "게이트" 역할             │  │  │  │
│  │  │  │  • up_proj (Linear): 업 프로젝션                   │  │  │  │
│  │  │  │    → hidden_size → intermediate_size 확장          │  │  │  │
│  │  │  │  • down_proj (Linear): 다운 프로젝션                │  │  │  │
│  │  │  │    → intermediate_size → hidden_size 축소          │  │  │  │
│  │  │  │                                                   │  │  │  │
│  │  │  │  ※ SwiGLU: Swish(gate) × up 으로 계산             │  │  │  │
│  │  │  │    → 기존 ReLU보다 성능이 좋은 활성화 함수           │  │  │  │
│  │  │  └───────────────────────────────────────────────────┘  │  │  │
│  │  │                                                         │  │  │
│  │  │  ※ 잔차 연결(Residual Connection):                     │  │  │
│  │  │    output = input + attn(norm(input))                  │  │  │
│  │  │    output = output + mlp(norm(output))                 │  │  │
│  │  │    → 그래디언트 소실 문제를 완화                         │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │ norm (LlamaRMSNorm)                                    │  │  │
│  │  │  - 마지막 트랜스포머 블록 출력을 최종 정규화              │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  │                                                               │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │ rotary_emb (LlamaRotaryEmbedding)                      │  │  │
│  │  │  - RoPE 회전 임베딩의 sin/cos 값을 미리 계산해두는 모듈  │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ lm_head (nn.Linear)                                          │  │
│  │  - 최종 은닉 벡터 → 어휘 크기(vocab_size)로 변환              │  │
│  │  - shape: (hidden_size, vocab_size)                           │  │
│  │  - 출력은 각 토큰이 다음에 올 확률(로짓)                       │  │
│  │  - softmax를 적용하면 확률 분포가 됨                           │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

★ 전체 추론 흐름 요약:
  1. 입력 토큰 ID → embed_tokens → 임베딩 벡터
  2. 각 디코더 레이어를 순서대로 통과:
     a) RMSNorm → Self-Attention (+ RoPE) → 잔차 연결
     b) RMSNorm → MLP (SwiGLU) → 잔차 연결
  3. 최종 RMSNorm → lm_head → 다음 토큰 확률(로짓)
  4. 로짓에서 가장 확률 높은 토큰 선택 (greedy) 또는 샘플링
"""
    print(explanations)


def inspect_layer_details(model) -> None:
    """
    ─────────────────────────────────────────────────
    [STEP 4] 각 레이어의 shape와 파라미터 수 상세 출력
    ─────────────────────────────────────────────────
    """
    print_separator("STEP 4: 레이어별 파라미터 shape 및 개수")

    for name, param in model.named_parameters():
        print(f"  {name:60s} | shape: {str(list(param.shape)):20s} | 파라미터 수: {param.numel():>12,}")

    print("\n[ shape 읽는 법 ]")
    print("  • embed_tokens.weight [vocab_size, hidden_size]")
    print("    → 각 토큰(vocab_size개)마다 hidden_size 차원의 벡터")
    print("  • q_proj.weight [num_heads × head_dim, hidden_size]")
    print("    → 입력 hidden_size를 Q 벡터로 변환")
    print("  • k_proj.weight [num_kv_heads × head_dim, hidden_size]")
    print("    → K 벡터 (GQA에서 Q보다 헤드 수가 적을 수 있음)")
    print("  • gate_proj.weight [intermediate_size, hidden_size]")
    print("    → FFN의 게이트: hidden → intermediate 확장")
    print("  • down_proj.weight [hidden_size, intermediate_size]")
    print("    → FFN의 다운: intermediate → hidden 축소")
    print("  • lm_head.weight [vocab_size, hidden_size]")
    print("    → 최종 출력: 은닉 벡터 → 어휘 확률")


def inspect_tokenizer(model_name: str) -> None:
    """
    ─────────────────────────────────────────────────
    [STEP 5] 토크나이저 확인
    ─────────────────────────────────────────────────
    """
    print_separator("STEP 5: 토크나이저 확인")

    tokenizer = AutoTokenizer.from_pretrained(model_name)

    print(f"\n토크나이저 타입: {type(tokenizer).__name__}")
    print(f"어휘 크기      : {tokenizer.vocab_size:,}")
    print(f"모델 최대 길이 : {tokenizer.model_max_length:,}")

    # 예시 문장 토크나이징
    test_sentences = [
        "Hello, how are you?",
        "Llama is a large language model.",
        "인공지능은 미래를 바꿀 것입니다.",
    ]

    print("\n[ 토크나이징 예시 ]")
    for sent in test_sentences:
        tokens = tokenizer.tokenize(sent)
        ids = tokenizer.encode(sent)
        print(f"\n  원문   : {sent}")
        print(f"  토큰   : {tokens}")
        print(f"  토큰 ID: {ids}")
        print(f"  토큰 수: {len(tokens)}")


def main():
    parser = argparse.ArgumentParser(
        description="Llama 3.2 1B 모델 구조 분석 스크립트"
    )
    parser.add_argument(
        "--model_name",
        type=str,
        default="meta-llama/Llama-3.2-1B",
        help="Hugging Face 모델 이름 (기본값: meta-llama/Llama-3.2-1B)",
    )
    parser.add_argument(
        "--skip_load",
        action="store_true",
        help="모델 가중치 로딩을 건너뛰고 config + 설명만 출력",
    )
    args = parser.parse_args()

    print("\n" + "█" * 70)
    print("  Llama 3.2 1B 모델 구조 분석기")
    print("  Model: " + args.model_name)
    print("█" * 70)

    # STEP 1: Config 확인 (가중치 다운로드 불필요)
    inspect_config(args.model_name)

    # STEP 3: 모듈 역할 설명 (항상 출력)
    explain_modules()

    if not args.skip_load:
        # STEP 2: 모델 로드 및 아키텍처 출력
        model = inspect_model_architecture(args.model_name)

        # STEP 4: 레이어 상세 출력
        inspect_layer_details(model)

        # STEP 5: 토크나이저 확인
        inspect_tokenizer(args.model_name)
    else:
        print("\n※ --skip_load 옵션이 활성화되어 모델 로딩을 건너뜁니다.")
        print("  Config와 구조 설명만 출력합니다.")

    print_separator("분석 완료!")


if __name__ == "__main__":
    main()
