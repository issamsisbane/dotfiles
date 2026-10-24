return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreviewStart", "MarkdownPreviewStop" },
  build = "cd app && npm install",
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_auto_close = 1
  end,
  keys = {
    { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
  },
}
