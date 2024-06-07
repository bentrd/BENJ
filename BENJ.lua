--- STEAMODDED HEADER
--- MOD_NAME: BEN'S JOKERS
--- MOD_ID: BENJ
--- MOD_AUTHOR: [Ben]
--- MOD_DESCRIPTION: Adds new jokers to the game
--- BADGE_COLOUR: dab3fc

----------------------------------------------
------------MOD CODE -------------------------

local mod_path = '' .. SMODS.current_mod.path

local files = NFS.getDirectoryItems(mod_path .. "mod")
for _, file in ipairs(files) do
    print("Loading file " .. file)
    local f, err = NFS.load(mod_path .. "mod/" .. file)
    if err then
        print("Error loading file: " .. err)
    else
        local curr_obj = f()
        if curr_obj.init then curr_obj:init() end
        for _, item in ipairs(curr_obj.items) do
            if SMODS[item.object_type] then
                SMODS[item.object_type](item)
            else
                print("Error loading item " .. item.key .. " of unknown type " .. item.object_type)
            end
        end
    end
end

if SMODS.Atlas then
    SMODS.Atlas({
        key = "modicon",
        path = "icon.png",
        px = 32,
        py = 32
    })
end


----------------------------------------------
------------MOD CODE END----------------------
