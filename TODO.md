# TODO — Production-grade fixes for reliable compression + explainability

## ✅ Current diagnosis (confirmed)
- Job is stuck in `EXECUTING: QUANTIZATION_4` for `facebook/opt-125m`.
- Quantization service logs show request reached “Loading facebook/opt-125m for CPU quantization”, but no subsequent “Quantized model saved” log yet.
- Orchestrator therefore never reaches `FEEDBACK_LOOP`, so:
  - `compression_ratio` and `speedup_factor` remain unset
  - UI compare page can’t show real gains

## Next implemented/To-implement (code changes)
- [ ] Orchestrator: add hard HTTP timeouts for `/quantize`, `/prune`, `/distill` calls.
- [ ] Orchestrator: on timeout or missing artifact dir, mark job `FAILED` with clear `error` + `details`.
- [ ] Orchestrator: persist `metrics_source` (estimated vs measured) and expose it to UI.
- [ ] Web UI: update comparison page to show a banner explaining why compression gains are missing:
  - “Feedback loop not reached” / “Artifact not visible locally” / “Technique timed out”.

## Acceptance criteria
For models: `gpt2`, `facebook/opt-125m`, `EleutherAI/pythia-70m`, `sshleifer/tiny-gpt2`
- [ ] Every job either:
  - [ ] reaches `COMPLETED` and populates:
    - `best_model_path`
    - `compression_ratio`
    - `speedup_factor`
    - final metrics
  - [ ] or reaches `FAILED` with a clear reason that UI displays.