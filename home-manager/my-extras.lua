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
-- Keybindings
--
-- =========================

vim.api.nvim_set_keymap('n', '<leader>rs', '<cmd>lua insert_random_string()<cr>', {noremap = true})
