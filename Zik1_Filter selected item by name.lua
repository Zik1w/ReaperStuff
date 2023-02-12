--[[
 * ReaScript Name: Filter selected item by name
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
 * v1.0 (2022-12-24) Init
--]]
 
-- USER CONFIG AREA ---------------------------------------------

-- Do you want a pop up to appear ?
CONFIG_UI_popup = true -- true/false use UI or not

-- Define here your default variables values
CONFIG_INPUT_1 = "" -- search token


-----------------------------------------------------------------

function main() -- local (i, j, item, take, track)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    selected_item_table = init_selected_item_table


    for _, item in pairs(selected_item_table) do
        cur_name_table = stringSplit(getItemName(item), "_")
        for _, token in pairs(search_token_table) do 
            if tableContains(cur_name_table, token) == nil then
                reaper.SetMediaItemSelected( item, false )
                break
            end
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


    if CONFIG_UI_popup == true then 

        defaultvals_csv = CONFIG_INPUT_1

        retval, retvals_csv = reaper.GetUserInputs("Filter by token", 1, "token list: ", defaultvals_csv)

        query_table = stringSplit(retvals_csv, ",")

        search_token = query_table[1]

        if retval then 

            if string.find(search_token, ";") then
                search_token_table = stringSplitIndex(search_token, ";")
            elseif string.find(search_token, "_") then 
                search_token_table = stringSplitIndex(search_token, "_")
            elseif string.find(search_token, "%s") then 
                search_token_table = stringSplitIndex(search_token, " ")
            elseif string.find(search_token, ",") then 
                search_token_table = stringSplitIndex(search_token, ",")
            elseif string.find(search_token, "%/") then 
                search_token_table = stringSplitIndex(search_token, "%/")
            else
                search_token_table = stringSplitIndex(search_token)
            end

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
    end
end


function stringIsEmpty(s)
    return s == nil or s == ""
end


function stringIsIndex(s)
    if string.find (s, "") then 
        local i,j = string.find (s, "")
        return string.sub(s, i, j)
    else
        return nil
    end
end


function stringSplitIndex(inputstr, ssi_sep)
  if ssi_sep == nil then
      ssi_sep = "%s"
  end

  if string.find(inputstr,ssi_sep) == nil then 
    return {inputstr}
  else
    ti_str = {} 
    local i = 1
    for str in string.gmatch(inputstr, "([^"..ssi_sep.."]+)") do
      table.insert(ti_str, i,str)
      i = i + 1
    end
    return ti_str
  end
end


-- LUA 
-- TABLE FUNC
function tableContains(table, element)
  for _, vv in pairs(table) do
    if vv == element then
      return true
    end
  end
  return nil
end


function tableLength(T)
  local cnt = 0
  for _ in pairs(T) do cnt = cnt + 1 end
  return cnt
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
    local take_name = string.gsub(reaper.GetTakeName(take), ".wav", "")
    return take_name
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
