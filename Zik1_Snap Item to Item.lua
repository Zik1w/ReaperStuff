--[[
 * ReaScript Name: Snap Item to Item
 * Author: Zik1
 * Author URI: 
 * Repository: 
 * Repository URI: https:
 * Licence: GPL v3
 * Forum Thread: Scripts: 
 * Forum Thread URI: 
 * REAPER: 6.7
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2022-12-03) init
--]]
 
-- USER CONFIG AREA ---------------------------------------------


-----------------------------------------------------------------


function main() -- local (i, j, item, take, track)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    reference_item = init_selected_item_table[1]

    for i, item in ipairs(init_selected_item_table) do
        if i ~= 1 then
            snapItem2Item(reference_item, item)
        end
    end

    reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.

end



function Init()
    -- START
    debug_table = {}

    -- Variables to be initiated
    init_selected_item_table = {}
    init_selected_track_table = {}
    init_selected_region_table = {}


    getSelectedItems(init_selected_item_table)
    getSelectedTracks(init_selected_track_table)
    getSelectedRegions(init_selected_region_table)


    reaper.PreventUIRefresh(1)

    reaper.ShowConsoleMsg("Executing...")

    --SaveView()
    --SaveCursorPos()
    --SaveLoopTimesel()
    --SaveSelectedItems(init_sel_items_table)
    --SaveSelectedTracks(init_sel_tracks_table)

    main()

    --SaveView()
    --SaveCursorPos()
    --SaveLoopTimesel()
    --SaveSelectedItems(init_sel_items_table)
    --SaveSelectedTracks(init_sel_tracks_table)

    reaper.PreventUIRefresh(-1)

    reaper.UpdateArrange()

    reaper.ShowConsoleMsg("\nDone!")

end


-- REAPER
-- ITEM FUNC

function getSelectedItems(t_item)
    item_t = {}
    for i = 0, reaper.CountSelectedMediaItems(0)-1  do
        table.insert(t_item, reaper.GetSelectedMediaItem(0, i)) 
    end
end

function snapItem2Item(item1, item2)
    value_set = reaper.GetMediaItemInfo_Value(item1, "D_POSITION")
    reaper.SetMediaItemInfo_Value(item2, "D_POSITION", value_set)
end


function getItemName(item)
    local take = reaper.GetActiveTake(item) 
    local take_name = reaper.GetTakeName(take)
    return take_name
end

function Log(msg) 
    reaper.ShowConsoleMsg(tostring(msg).."\n")
end


-- REAPER
-- REGION FUNC
function getSelectedRegions(t_region)
    i=0
    repeat
        retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0,i)
        if retval >= 1 then
            if isrgn == true then
                table.insert(t_region, markrgnindexnumber) 
            end
            i = i+1
        end
    until retval == 0
end


-- REAPER
-- TRACK FUNC
function getSelectedTracks(t_track)
    for i = 0, reaper.CountSelectedTracks(0)-1 do
        table.insert(t_track, reaper.GetTrack(0, i)) 
    end
end


-- REAPER
-- DEBUG FUNC
function Log(msg) 
    reaper.ShowConsoleMsg(tostring(msg).."\n")
end

--[[ <==== INITIAL SAVE AND RESTORE ----- 

-- LOOP AND TIME SELECTION
-- SAVE INITIAL LOOP AND TIME SELECTION
function SaveLoopTimesel()
  init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
  init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

-- RESTORE INITIAL LOOP AND TIME SELECTION
function RestoreLoopTimesel()
  reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
  reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
  init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
  reaper.SetEditCurPos(init_cursor_pos, false, false)
end

-- VIEW
--[[ SAVE INITIAL VIEW
function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end 


-- SAVE INITIAL TRACKS SELECTION
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  UnselectAllTracks()
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

-- <==== INITIAL SAVE AND RESTORE ----- ]]


if not preset_file_init then
    Init()
end
