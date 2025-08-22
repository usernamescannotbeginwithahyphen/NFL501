module Teams

export TEAM_ABBRS, ABBR_TO_NAME, NAME_TO_ABBR

const TEAM_ABBRS = [
 "ARI","ATL","BAL","BUF","CAR","CHI","CIN","CLE","DAL","DEN","DET","GB","HOU","IND","JAX","KC",
 "LAC","LAR","LV","MIA","MIN","NE","NO","NYG","NYJ","PHI","PIT","SEA","SF","TB","TEN","WAS"
]

const ABBR_TO_NAME = Dict(
 "ARI"=>"Arizona Cardinals","ATL"=>"Atlanta Falcons","BAL"=>"Baltimore Ravens","BUF"=>"Buffalo Bills",
 "CAR"=>"Carolina Panthers","CHI"=>"Chicago Bears","CIN"=>"Cincinnati Bengals","CLE"=>"Cleveland Browns",
 "DAL"=>"Dallas Cowboys","DEN"=>"Denver Broncos","DET"=>"Detroit Lions","GB"=>"Green Bay Packers",
 "HOU"=>"Houston Texans","IND"=>"Indianapolis Colts","JAX"=>"Jacksonville Jaguars","KC"=>"Kansas City Chiefs",
 "LAC"=>"Los Angeles Chargers","LAR"=>"Los Angeles Rams","LV"=>"Las Vegas Raiders","MIA"=>"Miami Dolphins",
 "MIN"=>"Minnesota Vikings","NE"=>"New England Patriots","NO"=>"New Orleans Saints","NYG"=>"New York Giants",
 "NYJ"=>"New York Jets","PHI"=>"Philadelphia Eagles","PIT"=>"Pittsburgh Steelers","SEA"=>"Seattle Seahawks",
 "SF"=>"San Francisco 49ers","TB"=>"Tampa Bay Buccaneers","TEN"=>"Tennessee Titans","WAS"=>"Washington Commanders"
)

const NAME_TO_ABBR = Dict(v=>k for (k,v) in ABBR_TO_NAME)

end
