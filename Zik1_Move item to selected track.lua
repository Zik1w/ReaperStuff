--[[
 * ReaScript Name: Move item to selected track
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
 * v1.0 (2022-12-15) init
--]]
 
-- USER CONFIG AREA ---------------------------------------------


-----------------------------------------------------------------

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- ACTION

  cur_track = reaper.GetSelectedTrack(0, 0)
  item_table = {}

  for i = 0, selected_items_count-1  do
		-- GET ITEMS
		Log(i)
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
		table.insert(item_table,item)
	end

	for i=1, tableLength(item_table) do
		reaper.MoveMediaItemToTrack(item_table[i],cur_track)
	end
  
  reaper.Undo_EndBlock("Action Done", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_array = {}

	-- GET COMMON VALUES
	selected_tracks_count = reaper.CountSelectedTracks(0)
	selected_items_count = reaper.CountSelectedMediaItems(0)

	if selected_items_count == 0 then
		Log("need to select a item!")
		return
	end

	if selected_tracks_count ~= 1 then
		Log("need to select one and only one track!")
		return
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


function stringSplit (inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  
  local table_str = {} 
  local i = 1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(table_str, i, str)
  end
  return table_str
end


function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function getItemName(item)
	local take = reaper.GetActiveTake(item) 
	local take_name = reaper.GetTakeName(take)
	return take_name
end

function tableLength(T)
  local cnt = 0
  for _ in pairs(T) do cnt = cnt + 1 end
  return cnt
end


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
