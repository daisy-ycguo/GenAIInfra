from huggingface_hub import snapshot_download
model_id="HuggingFaceH4/zephyr-7b-beta"
snapshot_download(repo_id=model_id, local_dir="zephyr-7b-beta",
    local_dir_use_symlinks=False, revision="main")