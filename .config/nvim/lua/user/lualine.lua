local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local function os_icon()
  local icons = {
    unix = "♜", -- e712
    dos = "☣︎", -- e70f
    mac = "👻", -- e711
  }
  if vim.fn.has("mac") == 1 then
    return icons.mac
  elseif vim.fn.has("win32") == 1 then
    return icons.dos
  else
    return icons.unix
  end
end

lualine.setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = " ", right = " " },
    section_separators = { left = " ", right = " " },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", os_icon, "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})
