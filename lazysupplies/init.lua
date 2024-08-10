--[[
    lazysupplies.lua by Shadow from RedGuides
    Version 1.0
    Original idea from a macro with same name made by Hellfyre in 2019.
    Converted to lua, and I am fairly new, so don't hate.
    Automated script to buy necessary supplies in PoK for most classes.
    The items/classes/level ranges to buy are contained in items.lua

    ** THIS IS A WORK IN PROGRESS **
]] 

local mq = require 'mq'
local imgui = require 'ImGui'
local supplies = require 'Items'  -- Include the supplies table from Items.lua

-- Variables for managing the GUI state
local open_gui = true
local running = false
local in_pok = false

local PoKnowledge = 202

-- Function to check if the current class is allowed to buy a specific supply item
local function is_class_allowed(classes)
    if not classes then return true end  -- Allow all classes if no specific classes are defined
    local player_class = mq.TLO.Me.Class.ShortName()
    for _, class in ipairs(classes) do
        if class == player_class then
            return true
        end
    end
    return false
end

-- Function to check if the player's level is within the specified range
local function is_level_in_range(level_range)
    if not level_range then return true end  -- No level range specified, allow all levels
    local player_level = mq.TLO.Me.Level()
    print(string.format("Player level: %d, required range: %d-%d", player_level, level_range[1], level_range[2]))
    return player_level >= level_range[1] and player_level <= level_range[2]
end

-- Function to find the spawn ID of a vendor by name with extended debug output
local function find_vendor_id(vendor_name)
    print(string.format("Attempting to find vendor: %s", vendor_name))
    
    -- Broad search by name only
    local vendor_spawn = mq.TLO.Spawn(string.format("%s", vendor_name))
    if vendor_spawn() then
        print(string.format("Vendor %s found! Name: %s, ID: %d", vendor_name, vendor_spawn.CleanName(), vendor_spawn.ID()))
        return vendor_spawn.ID()
    else
        print(string.format("Vendor %s not found in broad search.", vendor_name))
    end

    -- If not found, return nil
    print(string.format("Vendor %s could not be found after all searches.", vendor_name))
    return nil
end

-- Function to navigate to a vendor by their ID
local function nav_to_vendor(vendor_id)
    if vendor_id then
        print("Navigating to vendor with ID: " .. vendor_id)
        mq.cmdf('/nav id %d', vendor_id)
        mq.delay(2000, function() return not mq.TLO.Navigation.Active() end)  -- Wait up to 2s or until navigation is active

        while mq.TLO.Navigation.Active() do
            if mq.TLO.Spawn(string.format("id %d", vendor_id)).Distance3D() > 15 then
                mq.delay(5000)  -- Wait for 5s if the distance is still greater than 15 units
            else
                break  -- Break out of the loop if close enough
            end
        end

        if mq.TLO.Spawn(string.format("id %d", vendor_id)).Distance3D() < 15 then
            mq.cmdf('/target id %d', vendor_id)
            mq.delay(2000, function() return mq.TLO.Target.ID() == vendor_id end)  -- Wait up to 2s for targeting
            mq.cmd('/face fast')  -- Face the vendor quickly
        end
    else
        print("Unable to navigate to vendor: Invalid vendor ID")
    end
end

-- Function to echo current item count and purchasing status
local function echo_item_status(supply)
    local current_count = mq.TLO.FindItemCount(supply.name)()
    print(string.format("Current %s count: %d/%d", supply.name, current_count, supply.quantity))
    if current_count < supply.quantity then
        print(string.format("\ayI only have \ar%d \ay%s. Let's go get more.", current_count, supply.name))
    end
end

-- Function to buy supplies from the appropriate vendors
local function buy_item(supply)
    local count_before = mq.TLO.FindItemCount(supply.name)()
    local qty_needed = supply.quantity - count_before

    if qty_needed <= 0 then
        print(string.format("Already have enough %s.", supply.name))
        return
    end

    local list_item = mq.TLO.Window("MerchantWnd").Child("ItemList").List(string.format("=%s", supply.name), 2)()
    if not list_item then
        print(string.format("Could not find %s in the merchant window.", supply.name))
        return
    else
        mq.cmdf('/notify MerchantWnd ItemList listselect %d', list_item)
        mq.delay(500)
    end

    print(string.format("Buying %s until we have %d.", supply.name, supply.quantity))

    while qty_needed > 0 do
        local current_count = mq.TLO.FindItemCount(supply.name)()
        local buy_amount = math.min(qty_needed, 1000)

        mq.cmdf('/buyitem %d', buy_amount)
        mq.delay(3000, function() return mq.TLO.FindItemCount(supply.name)() > current_count end)

        qty_needed = supply.quantity - mq.TLO.FindItemCount(supply.name)()
        print(string.format("Current count of %s: %d/%d", supply.name, mq.TLO.FindItemCount(supply.name)(), supply.quantity))

        if mq.TLO.FindItemCount(supply.name)() <= current_count then
            print(string.format("Failed to buy more %s, stopping.", supply.name))
            break
        end
    end
end

-- Main function to buy supplies
local function buy_supplies()
    if type(supplies) ~= "table" then
        print("Error: Supplies table not loaded correctly.")
        return
    end

    for _, supply in ipairs(supplies) do
        print(string.format("Checking supply: %s", supply.name))
        local is_class_valid = is_class_allowed(supply.classes)
        local is_level_valid = is_level_in_range(supply.level_range)
        local is_count_valid = tonumber(mq.TLO.FindItemCount(supply.name)()) < supply.quantity
        --print(string.format("Class valid: %s, Level valid: %s, Count valid: %s", tostring(is_class_valid), tostring(is_level_valid), tostring(is_count_valid)))

        if is_class_valid and is_level_valid and is_count_valid then
            echo_item_status(supply)
            local vendor_id = find_vendor_id(supply.vendor)
            if vendor_id then
                nav_to_vendor(vendor_id)
                print("Interacting with vendor ID: " .. vendor_id)
                mq.cmd("/squelch /target id " .. vendor_id)
                mq.delay(1000)
                mq.cmd("/squelch /click right target")
                mq.delay(3000)  -- Ensure interaction with the vendor

                -- Wait until the merchant window is open
                if mq.TLO.Window("MerchantWnd").Open() then
                    print("Merchant window opened.")
                    buy_item(supply)
                else
                    print("Merchant window did not open.")
                end
            else
                print(string.format("Could not find vendor for %s.", supply.name))
            end
        end
    end

    -- Close the merchant window after purchasing
    if mq.TLO.Window("MerchantWnd").Open() then
      mq.TLO.Window('MerchantWnd').DoClose()
      mq.delay(500)  -- Ensure the window closes properly
    end

    print("Lazysupplies: Supplies purchased")
    mq.cmd("/lua stop lazysupplies")  -- Automatically stop the script after purchasing supplies
end

-- Function to check if the player is in Plane of Knowledge
local function check_pok()
    in_pok = (mq.TLO.Zone.ID() == PoKnowledge)
end

-- ImGui Callback Function to manage the GUI
local function lazysupplies_gui()
    if imgui.Begin("Lazysupplies", open_gui) then
        imgui.Text("Manage your supplies")
        
        if not in_pok then
            imgui.TextColored(1, 0, 0, 1, "You must be in Plane of Knowledge to run this script.")
        else
          if imgui.Button(running and "Stop" or "Start") then
            running = not running
        end

        -- Add spacing and place End button next to Start/Stop button
        imgui.SameLine()
        if imgui.Button("End") then
            running = false
            print("Lazysupplies: Script ended by user.")
            mq.cmd("/lua stop lazysupplies")  -- Stop the Lua script
            imgui.End()  -- Ensure we end the ImGui frame before stopping
            return  -- Exit the function early to avoid further ImGui processing
        end
    end
    
    imgui.End()
end
end

-- Register the ImGui callback
mq.imgui.init('Lazysupplies', lazysupplies_gui)

-- Main execution loop
mq.bind('/lazysupplies', function()
open_gui = true
end)

-- Main loop for managing the script
while true do
if mq.TLO.MacroQuest.GameState() == 'INGAME' then
    check_pok() -- Check if player is in PoK
    if open_gui then
        lazysupplies_gui() -- Manage the GUI each loop iteration
    end
    if running and in_pok then
        buy_supplies()
    end
end
mq.delay(50)
end

