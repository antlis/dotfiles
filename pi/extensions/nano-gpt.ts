// nano-gpt provider for pi (https://pi.dev).
//
// nano-gpt is an OpenAI-compatible gateway and is NOT a pi built-in (unlike
// openrouter and opencode-zen, which only need `/login`). So we register it
// here with `pi.registerProvider`.
//
// API key: read from $NANO_GPT_API_KEY (kept out of this repo). Set it in your
// shell, e.g. `export NANO_GPT_API_KEY=...`. If you'd rather reuse the key you
// already have in opencode, replace the apiKey line below with:
//   apiKey: `!jq -r '."nano-gpt".key' ~/.local/share/opencode/auth.json`,
//
// Models are discovered dynamically from the gateway's OpenAI-compatible
// /models endpoint so we don't hardcode (and drift on) model IDs. If discovery
// fails (no key, offline), we fall back to a small curated list.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BASE_URL = "https://nano-gpt.com/api/v1";

type PiModel = {
  id: string;
  name: string;
  reasoning: boolean;
  input: ("text" | "image")[];
  cost: { input: number; output: number; cacheRead: number; cacheWrite: number };
  contextWindow: number;
  maxTokens: number;
};

const ZERO_COST = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };

// Used only when /models can't be reached. IDs mirror the nano-gpt catalog.
const FALLBACK_MODELS: PiModel[] = [
  { id: "zai-org/glm-5", name: "GLM 5", reasoning: false, input: ["text"], cost: ZERO_COST, contextWindow: 200000, maxTokens: 8192 },
  { id: "zai-org/glm-5:thinking", name: "GLM 5 (thinking)", reasoning: true, input: ["text"], cost: ZERO_COST, contextWindow: 200000, maxTokens: 8192 },
  { id: "qwen/qwen3-coder-next", name: "Qwen3 Coder", reasoning: false, input: ["text"], cost: ZERO_COST, contextWindow: 256000, maxTokens: 8192 },
  { id: "deepseek/deepseek-v3.2", name: "DeepSeek V3.2", reasoning: false, input: ["text"], cost: ZERO_COST, contextWindow: 128000, maxTokens: 8192 },
  { id: "deepseek/deepseek-v3.2:thinking", name: "DeepSeek V3.2 (thinking)", reasoning: true, input: ["text"], cost: ZERO_COST, contextWindow: 128000, maxTokens: 8192 },
  { id: "moonshotai/kimi-k2.5", name: "Kimi K2.5", reasoning: false, input: ["text"], cost: ZERO_COST, contextWindow: 256000, maxTokens: 8192 },
];

async function discoverModels(): Promise<PiModel[]> {
  const key = process.env.NANO_GPT_API_KEY;
  if (!key) return FALLBACK_MODELS;

  try {
    const res = await fetch(`${BASE_URL}/models`, {
      headers: { Authorization: `Bearer ${key}` },
    });
    if (!res.ok) return FALLBACK_MODELS;

    const payload = (await res.json()) as {
      data?: Array<{ id: string; name?: string; context_window?: number; max_tokens?: number }>;
    };
    const data = payload.data ?? [];
    if (data.length === 0) return FALLBACK_MODELS;

    return data.map((m) => ({
      id: m.id,
      name: m.name ?? m.id,
      reasoning: /think|reason/i.test(m.id),
      input: ["text"],
      cost: ZERO_COST,
      contextWindow: m.context_window ?? 128000,
      maxTokens: m.max_tokens ?? 8192,
    }));
  } catch {
    return FALLBACK_MODELS;
  }
}

export default async function (pi: ExtensionAPI) {
  pi.registerProvider("nano-gpt", {
    name: "Nano GPT",
    baseUrl: BASE_URL,
    apiKey: "$NANO_GPT_API_KEY",
    api: "openai-completions",
    models: await discoverModels(),
  });
}
