--[[
 * ReaScript Name: Clear Section in region render matrix
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
 * v1.0 (2022-11-02) init
--]]
 
-- USER CONFIG AREA ---------------------------------------------


-----------------------------------------------------------------

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


	repeat
		local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, idx_rgnnumber ) -- get built-in region/marker index by timeline index
  	if isrgn then -- if it is a region and not a marker
  		reaper.SetRegionRenderMatrix(0, markrgnindexnumber, reaper.GetMasterTrack(0), -1)  -- clear master mix
  		idx_tracknumber = 0
  		while idx_tracknumber < idx_tracknumber_max
  		do
    		reaper.SetRegionRenderMatrix(0, markrgnindexnumber, reaper.GetTrack(0, idx_tracknumber), -1) -- clear track region
    		idx_tracknumber = idx_tracknumber + 1
    	end
    end
  	idx_rgnnumber = idx_rgnnumber + 1 -- increment idx
	until retval == 0

  
  reaper.Undo_EndBlock("Clear Selection in region render matrix", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_table = {}

	idx_rgnnumber = 0
	idx_tracknumber_max = reaper.CountTracks(0)

	reaper.PreventUIRefresh(1)

	reaper.ShowConsoleMsg("Clearing...")

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

	reaper.ShowConsoleMsg("\nClearing Done!")

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
