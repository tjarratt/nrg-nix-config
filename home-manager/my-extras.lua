local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- =========================
--
-- code folding
--
-- =========================

vim.o.foldmethod=syntax
vim.o.foldcolumn = '1' -- '0' is not bad
vim.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup()
-- =========================
--
-- random strings
--
-- =========================

math.randomseed(os.time())

local vanilla_dictionary = {}
local function load_vanilla_dictionary()
    if #vanilla_dictionary == 0 then
        local file = io.open("/usr/share/dict/words", "r")
        if file then
            for line in file:lines() do
                table.insert(vanilla_dictionary, line)
            end
            file:close()
        end
    end
end

local function random_word()
    return vanilla_dictionary[math.random(#vanilla_dictionary)]
end

local function random_string_vanilla()
    load_vanilla_dictionary()
    return random_word() .. "-" .. random_word()
end

function insert_random_string()
   string = random_string_vanilla()

   vim.fn.feedkeys('i', 'n')
   vim.fn.feedkeys(string, 'n')
   vim.api.nvim_input('<ESC>')
end

-- =========================
--
-- UFO
--
-- =========================

-- capabilities.textDocument.foldingRange = {
--     dynamicRegistration = false,
--     lineFoldingOnly = true
-- }
--
-- vim.o.foldcolumn = '1' -- '0' is not bad
-- vim.foldlevel = 99
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true
--
-- require('ufo').setup()
--
-- --local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
-- local language_servers = { 'elixirls' }
-- for _, ls in ipairs(language_servers) do
-- 	require('lspconfig')[ls].setup({
-- 		capabilities = capabilities,
-- 		settings = {
-- 			Lua = {
-- 				diagnostics = { globals = { 'vim' } }
-- 			}
-- 		}
-- 		-- you can add other fields for setting up lsp server in this table
-- 	})
-- end


-- =========================
--
-- Keybindings
--
-- =========================

vim.api.nvim_set_keymap('n', '<leader>rs', '<cmd>lua insert_random_string()<cr>', {noremap = true})
