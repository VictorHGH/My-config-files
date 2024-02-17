local configs = require("nvim-treesitter.configs")
configs.setup({
  ensure_installed = {
    "bash",
    "css",
    "html",
    "javascript",
    "ninja",
    "markdown",
    "python",
    "scss",
    "tsx",
    "typescript",
    "lua",
    "astro",
    "json",
    "htmldjango",
    "http",
    "csv",
    "php",
    "cpp",
    "c",
    "c_sharp",
    "vim",
  },

  sync_install = false,
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,         -- false will disable the whole extension
    disable = { "" },      -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = {} },
  ts_context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  autopairs = {
    enable = true,
  },
})
