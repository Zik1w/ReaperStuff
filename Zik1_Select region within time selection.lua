--[[
 * ReaScript Name: Select region within time selection
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
 * v1.0 (2022-12-23) init
--]]
 
-- USER CONFIG AREA ---------------------------------------------

-- Do you want a pop up to appear ?
popup = true -- true/false

-- Define here your default variables values
select_master_track = "y" -- y/n for whether select master mix
select_track = "0" -- % for escaping characters


-----------------------------------------------------------------

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- ACTION
  ts_start, ts_end = reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false )
  idx_rgnnumber = 0 -- timeline region index


	if ts_start == ts_end then
	  reaper.ShowMessageBox("No Time selection", "Info", 0)
	  return
	end

	repeat
		retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, idx_rgnnumber ) -- get built-in region/marker index by timeline index

  	if isrgn and pos >= ts_start and rgnend <= ts_end then -- if it is a region and not a marker
			if select_master_track == "y" then 
				reaper.SetRegionRenderMatrix(0, markrgnindexnumber, reaper.GetMasterTrack(0), 1)
			end 

			if track_idx ~= 0 then 
				reaper.SetRegionRenderMatrix(0, markrgnindexnumber, reaper.GetTrack(0, track_idx-1), 1) 
			elseif multi_track then 
				for i = track_t[1], track_t[2], 1 do 
					reaper.SetRegionRenderMatrix(0, markrgnindexnumber, reaper.GetTrack(0, i-1), 1)
				end
			end
		end


  	idx_rgnnumber = idx_rgnnumber + 1
	until retval == 0
	
  
  reaper.Undo_EndBlock("Action Done", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_array = {}

	if popup == true then 

		defaultvals_csv = select_master_track .. "," .. select_track

		retval, retvals_csv = reaper.GetUserInputs("Select tracks", 2, "Select Master Mix? (y/n),Tracks(#X; m:n for #m to #n; 0 for none)", defaultvals_csv)

		-- retrieve user input info

		user_input_table = split(retvals_csv, ",")
		select_master_track = user_input_table[1]
		select_track = user_input_table[2]

		track_idx = 0 
		track_t = {}
		multi_track = false


		if retval then -- if user compelte the fields

			if string.find(select_track, ":") then

				multi_track = true 
				sep = ":"
			  for str in string.gmatch(select_track, "([^"..sep.."]+)") do
			  	table.insert(track_t, str)
				end

	  	else 

	  		track_idx = tonumber(select_track)

	  	end 


			reaper.PreventUIRefresh(1)

			reaper.ShowConsoleMsg("Select all regions...")

			main()

			reaper.PreventUIRefresh(-1)

			reaper.UpdateArrange()

			reaper.ShowConsoleMsg("\nDone!")
		end


	else 

		reaper.PreventUIRefresh(1)

		reaper.ShowConsoleMsg("Select all regions...")

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


function split (inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  
  table_str = {} 
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(table_str, str)
  end
  return table_str
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
