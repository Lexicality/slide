--- A round lasts from everyone spawning, until two players each of a different team have fought to the death or finished for over a minute (or 1 player if playing solo).

--- The round we're playing at
GM.Round = 1

--- The amount of seconds between two players finishing and the round forcibly restarting
GM.RoundEndGraceConVar = CreateConVar("slide_round_end_grace", 60, nil, "The time between two players of different teams finishing and the round ending.", 1)

local STALLING_TIMER_NAME = "PreventRoundStalling"

--- Make a player join a round
--- @param ply GPlayer
function GM:JoinRound(ply)
  ply.RoundNumber = self.Round
end

--- Resets a round, cleaning up the map and allowing everybody to respawn
function GM:ResetRound()
  local newRoundNumber = self.Round + 1
  PrintMessage(HUD_PRINTTALK, string.format("Starting new round (#%s)!", newRoundNumber))

  timer.Remove(STALLING_TIMER_NAME)

  -- Kill all other players silently
  for _, ply in pairs(player.GetAll()) do
    if(IsValid(ply) and ply:Alive())then
      ply:KillSilent()
    end
  end

  -- Do this in a timer, so we don't remove an invalid entity (like the skull that spawns on death, or ragdoll??)
  -- Prevents a crash by doing game.CleanUpMap in a timer, unsure why
  timer.Simple(0, function()
    -- Quick workaround for issue @ https://github.com/Facepunch/garrysmod-issues/issues/3637
    game.CleanUpMap(false, {"env_fire", "entityflame", "_firesmoke"})
  
    self.IsResetQueued = nil
  
    self.Round = newRoundNumber
    
    -- Respawn everyone
    for _, teamID in ipairs(self.PlayingTeams) do
      local players = team.GetPlayers(teamID)

      for _, ply in ipairs(players) do
        ply:Spawn()
      end
    end
  end)
end

--- Checks if the round has ended by looking at all players
function GM:CheckRoundEnd()
  local numPlaying = 0

  -- If of one team everyone has died, reset
  for _, teamID in ipairs(self.PlayingTeams) do
    local players = team.GetPlayers(teamID)
    local liveCount = 0

    numPlaying = numPlaying + #players

    for _, ply in ipairs(players) do
      if(ply:Alive())then
        liveCount = liveCount + 1
      end
    end

    -- If we got this far and all players of this team are dead, then reset
    if(liveCount == 0 and #players > 0)then
      PrintMessage(HUD_PRINTTALK, "All players of team " .. team.GetName(teamID) .. " have died!")
      self:ResetRound()
      return true
    end
  end

  -- If playing solo, reset on death, finish or disconnect
	if(numPlaying < 2)then
		self:ResetRound()
		return true
  end
end

--- When a player crosses the finish line check if we should set a timer to prevent stalling
function GM:PlayerFinishedRound(ply)
  if(self.IsResetQueued)then
    return
  end

  if(not self:CheckRoundEnd())then
    timer.Create(STALLING_TIMER_NAME, self.RoundEndGraceConVar:GetInt(), function()
      PrintMessage(HUD_PRINTTALK, "Players took too long to kill eachother! Ending the round now.")
      self:ResetRound()
    end)
    
    self.IsResetQueued = true
  end
end