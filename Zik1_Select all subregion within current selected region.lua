--[[
 * ReaScript Name: Select all subregion within current selected regions
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
 * v1.1 (2022-01-20) clean up
--]]
 
-- USER CONFIG AREA ---------------------------------------------

-- Do you want a pop up to appear ?
CONFIG_UI_popup = true -- true/false

-- Define here your default variables values
select_subregion = "y" --y/n for to also select subregion
select_master_track = "y" -- y/n for whether select master mix
select_track = "0" -- % for escaping characters

-----------------------------------------------------------------

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  	local idx_rgnnumber = 0

	repeat
		retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, idx_rgnnumber ) -- get built-in region/marker index by timeline index
		cur_idx = idx_rgnnumber
  	if isrgn then -- if it is a region and not a marker
  		if reaper.EnumRegionRenderMatrix(0, markrgnindexnumber, 0) then  -- if the region is selected in RRM

				cur_rgend = pos

				if select_subregion == "y" then  -- select all subregion

	  			while cur_rgend <= rgnend and cur_retval ~= 0 
	  			do 
	  				cur_retval, _, _, cur_rgend, _, cur_builtin_idx, _ = reaper.EnumProjectMarkers3( 0, cur_idx )
	  				
	  				if cur_rgend <= rgnend then 

	  					if select_master_track == "y" then 
	  						reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetMasterTrack(0), 1)
	  					end 

	  					if track_idx ~= 0 then 
	  						reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetTrack(0, track_idx-1), 1) 
	  					elseif multi_track then 
	  						for i = track_t[1], track_t[2], 1 do 
	  							reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetTrack(0, i-1), 1)
	  						end
	  					end

	  				end 
	  				
	  				cur_idx = cur_idx + 1
	  			
	  			end

	  		else -- only select track within selected region

	  			cur_retval, _, _, cur_rgend, _, cur_builtin_idx, _ = reaper.EnumProjectMarkers3( 0, cur_idx )

				  if select_master_track == "y" then 
						reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetMasterTrack(0), 1)
					end 

					if track_idx ~= 0 then 
						reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetTrack(0, track_idx-1), 1) 
					elseif multi_track then 
						for i = track_t[1], track_t[2], 1 do 
							reaper.SetRegionRenderMatrix(0, cur_builtin_idx, reaper.GetTrack(0, i-1), 1)
						end
					end

	  		end  

  		end 
  	end 
  	
  		idx_rgnnumber = cur_idx + 1

	until retval == 0
  
  reaper.Undo_EndBlock("Select all subregion within current selected regions", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
	-- START
	debug_array = {}

	if CONFIG_UI_popup == true then 

		defaultvals_csv = select_subregion .."," .. select_master_track .. "," .. select_track

		retval, retvals_csv = reaper.GetUserInputs("Select tracks", 3, "Select Subregion? (y/n), Select Master Mix? (y/n),Tracks(#X; m:n for #m to #n; 0 for none)", defaultvals_csv)

		query_table = stringSplit(retvals_csv, ",")
		select_subregion = query_table[1]
		select_master_track = query_table[2]
		select_track = query_table[3]

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

-- LUA
-- STRING FUNC
function stringSplit (inputstr, sep)
  if sep == nil then
      sep = "%s"
  end
  
  table_str = {} 
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(table_str, str)
  end
  return table_str
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
