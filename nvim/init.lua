-- Lazy.nvim bootstrap (plugin manager setup)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugins
require("lazy").setup({
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },

  { "nvim-tree/nvim-tree.lua" }, -- file sidebar
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "lewis6991/gitsigns.nvim" },
  { "nvimtools/none-ls.nvim" },
  { "folke/tokyonight.nvim" },
})

-- General editor settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.g.mapleader = " "

-- Theme setup
vim.cmd.colorscheme("tokyonight-night")

-- LSP setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "tsserver", "eslint", "html", "cssls", "jsonls" }
})

local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({})
lspconfig.eslint.setup({})
lspconfig.html.setup({})
lspconfig.cssls.setup({})
lspconfig.jsonls.setup({})

-- Autocomplete (cmp) config
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- File sidebar (nvim-tree) setup
require("nvim-tree").setup({
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        git = false,
        folder = false,
        file = false,
        folder_arrow = false,
      }
    }
  },
  git = {
    enable = false,
  }
})

-- Toggle file sidebar with Ctrl+n
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Telescope shortcuts
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", {})
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", {})

-- Git signs config (without icons or signs)
require("gitsigns").setup({
  signs = false,
  numhl = true,
})

-- Formatter and linter setup (using null-ls)
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
  },
})

-- Format on save for TS/JS files
vim.cmd [[autocmd BufWritePre *.ts,*.tsx,*.js,*.jsx lua vim.lsp.buf.format()]]

-- LSP key mappings
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
