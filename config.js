// Konfigurasi ArcZ - Ai. Ubah nilai di bawah ini.
// PERINGATAN: file ini ikut terkirim ke browser, jadi siapa pun yang membuka
// web Anda bisa melihat API key. Pakai key khusus yang kuotanya kecil.
window.ARCZ_CONFIG = {
  BASE_URL: "https://bandelbanget.xyz/v1",
  API_KEY: "sk-qwen-02d12249413a6f0fd37dc6088c37c5eb4a027c632e806a57",
  DEFAULT_MODEL: "glm-5.2",
  // Dipakai jika daftar model dari server gagal dimuat
  FALLBACK_MODELS: ["auto","glm-5.2","glm-5.3","glm-5.3-flash","deepseek-v4-flash","deepseek-v4-flash-vision-exp","deepseek-v4-pro","kimi-k2.8","gpt-5.6","gpt-5.6-luna","claude-opus-5","mimo-v2.6-pro"]
};
