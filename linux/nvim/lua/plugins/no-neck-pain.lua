-- ~/.config/nvim/lua/plugins/no-neck-pain.lua
return {
  "shortcuts/no-neck-pain.nvim",
  opts = {
    width = 120,
  },
  config = function(_, opts)
    require("no-neck-pain").setup(opts)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        require("no-neck-pain").enable()
      end,
    })
  end,
}
