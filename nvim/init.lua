-- Plugin manager setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "neovim/nvim-lspconfig" },            -- LSP client
  { "williamboman/mason.nvim" },          -- LSP installer
  { "williamboman/mason-lspconfig.nvim" },-- LSP config helper

  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },

  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "lewis6991/gitsigns.nvim" },

  { "stevearc/conform.nvim" },            -- Formatter
  { "mfussenegger/nvim-lint" },           -- Diagnostics

  { "folke/tokyonight.nvim" },
})

-- Basic settings
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

vim.cmd.colorscheme("tokyonight-night")

-- LSP installer + setup
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "ts_ls", "eslint", "html", "cssls", "jsonls" }
})

local lspconfig = require("lspconfig")
lspconfig.ts_ls.setup({})
lspconfig.eslint.setup({})
lspconfig.html.setup({})
lspconfig.cssls.setup({})
lspconfig.jsonls.setup({})

-- Autocomplete configuration
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
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

-- File explorer sidebar
require("nvim-tree").setup({
  view = { width = 30, side = "left" },
})
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Fuzzy search
vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")

-- Git signs in gutter
require("gitsigns").setup()

-- Formatter setup via conform
require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    ["*"] = { "trim_whitespace" },
  },
})
vim.keymap.set("n", "<leader>f", require("conform").format, { desc = "Format file" })

-- Diagnostics setup via nvim-lint
require("lint").linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
}
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Keybindings for LSP actions
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
