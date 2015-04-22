
GM.Name 	= "Slide"
GM.Author 	= "Lexi"
GM.Email 	= "lexi@lexi.org.uk"
GM.Website 	= "http://lexi.org.uk"
GM.Version  = "0.0.1"
GM.Help		= "Slide from one end of the map to the other without dying horribly (Easier said than done)"

DeriveGamemode( "base" )
include "player_class/class_default.lua"

MsgN("Slide!")

TEAM_RED    = 2
TEAM_BLUE   = 3

function GM:CreateTeams()

	team.SetUp( TEAM_RED, "Team Red", Color( 255, 75, 67 ) )
	team.SetSpawnPoint( TEAM_RED, "info_player_terrorist", true )

	team.SetUp( TEAM_BLUE, "Team Blue", Color( 39, 186, 255 ) )
	team.SetSpawnPoint( TEAM_BLUE, "info_player_counterterrorist", true )

	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_terrorist" } )

end

