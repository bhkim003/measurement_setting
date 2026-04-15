# Llama 3.2 1B — lm_eval 벤치마크 실행 가이드

이 폴더는 **Llama 3.2 1B** 모델을 **lm_eval**(Language Model Evaluation Harness)로
평가하기 위한 코드 모음입니다.

---

## 📁 파일 구성

| 파일 | 설명 |
|------|------|
| `run_lm_eval.sh` | **원스톱 실행 스크립트** — venv 생성, 패키지 설치, 모델 분석, lm_eval 실행까지 한번에 |
| `inspect_model.py` | 모델 구조 분석 — 각 레이어/모듈의 역할을 한글 주석으로 상세히 출력 |
| `run_lm_eval_benchmark.py` | lm_eval Python API 사용 — CLI 대신 Python 코드로 벤치마크 실행 |

---

## 🚀 빠른 시작

### 1. Hugging Face 토큰 준비
Llama 3.2는 **gated model**이므로 먼저 접근 권한이 필요합니다:
1. [Hugging Face](https://huggingface.co/)에서 계정 생성
2. [Llama 3.2 모델 페이지](https://huggingface.co/meta-llama/Llama-3.2-1B)에서 라이선스 동의
3. [토큰 생성](https://huggingface.co/settings/tokens)

```bash
# 방법 1: CLI 로그인
huggingface-cli login

# 방법 2: 환경변수 설정
export HF_TOKEN="hf_여러분의_토큰"
```

### 2. 실행
```bash
cd llama3_lm_eval
chmod +x run_lm_eval.sh
./run_lm_eval.sh
```

### 3. 모델 구조만 보고 싶을 때
```bash
# 가중치 다운로드 없이 config + 구조 설명만
python inspect_model.py --skip_load

# 가중치까지 다운로드하고 전체 분석
python inspect_model.py
```

### 4. Python API로 직접 실행하고 싶을 때
```bash
python run_lm_eval_benchmark.py \
    --model_name meta-llama/Llama-3.2-1B \
    --tasks "hellaswag,arc_easy,piqa" \
    --device cuda:0 \
    --batch_size auto
```

---

## 📊 lm_eval 주요 태스크 요약

| 태스크 | 측정 능력 | 난이도 | 설명 |
|--------|-----------|--------|------|
| `hellaswag` | 상식 추론 | 중 | 문장 이어지기 4지선다 |
| `arc_easy` | 과학 상식 | 하 | 초등 수준 과학 문제 |
| `arc_challenge` | 과학 추론 | 중상 | 어려운 과학 문제 |
| `winogrande` | 대명사 해석 | 중 | 빈칸 채우기 2지선다 |
| `piqa` | 물리적 상식 | 중 | 물리적 상황 2지선다 |
| `boolq` | 독해 | 하~중 | 예/아니오 질의응답 |
| `openbookqa` | 과학+추론 | 중상 | 오픈북 과학 시험 |
| `mmlu` | 종합 지식 | 상 | 57개 분야 종합 (느림) |
| `truthfulqa_mc2` | 신뢰성 | 중상 | 오해하기 쉬운 질문 |
| `gsm8k` | 수학 추론 | 중상 | 초등 수학 서술형 |

---

## ⚙️ 설정 커스터마이즈

`run_lm_eval.sh` 상단의 변수를 수정하세요:

```bash
MODEL_NAME="meta-llama/Llama-3.2-1B"          # 모델 변경
TASKS="hellaswag,arc_easy,winogrande,piqa,boolq"  # 태스크 변경
DEVICE="cuda:0"                                 # GPU 번호 (cpu도 가능)
BATCH_SIZE="auto"                               # 배치 크기
```

---

## 💡 팁

- **GPU 메모리가 부족하면**: `BATCH_SIZE`를 `1`이나 `2`로 줄이세요
- **CPU에서 돌리려면**: `DEVICE="cpu"`로 변경 (매우 느림)
- **특정 태스크만**: `TASKS="hellaswag"` 처럼 하나만 지정 가능
- **few-shot 평가**: `--num_fewshot 5` 옵션 추가 (예제 5개 제공)
