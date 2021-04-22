local QActorDamageView = class("QActorDamageView", function()
    return display.newNode()
end)

local FONT_TREAT = "fight_g"
local FONT_ENMEY_DAMAGE = "fight_y"
local FONT_ENMEY_DAMAGE_CRITICAL = "fight_r"
local FONT_HERO_DAMAGE = "fight_rr"
local FONT_RAGE = "fight_b"

local FONT_RANGE = {}
-- FONT_RANGE[0] = {0.7/9.5, 1 - 3.4/9.5}
-- FONT_RANGE[1] = {2.0/9.5, 1 - 4.9/9.5}
-- FONT_RANGE[2] = {1.5/9.5, 1 - 2.9/9.5}
-- FONT_RANGE[3] = {1.7/9.5, 1 - 3.4/9.5}
-- FONT_RANGE[4] = {1.0/9.5, 1 - 3.2/9.5}
-- FONT_RANGE[5] = {1.4/9.5, 1 - 3.2/9.5}
-- FONT_RANGE[6] = {1.2/9.5, 1 - 3.4/9.5}
-- FONT_RANGE[7] = {1.0/9.5, 1 - 4.0/9.5}
-- FONT_RANGE[8] = {1.2/9.5, 1 - 3.5/9.5}
-- FONT_RANGE[9] = {1.1/9.5, 1 - 3.3/9.5}

local FONT_RANGES = {}

local FONT_RANGE = {}
FONT_RANGES[FONT_TREAT] = FONT_RANGE

FONT_RANGE[0] = {}
FONT_RANGE[1] = {}
FONT_RANGE[2] = {}
FONT_RANGE[3] = {}
FONT_RANGE[4] = {}
FONT_RANGE[5] = {}
FONT_RANGE[6] = {}
FONT_RANGE[7] = {}
FONT_RANGE[8] = {}
FONT_RANGE[9] = {}

FONT_RANGE[0][0] = {0.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[0][1] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][2] = {0.7/9.5, 1 - 3.1/9.5}
FONT_RANGE[0][3] = {0.7/9.5, 1 - 2.8/9.5}
FONT_RANGE[0][4] = {0.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[0][5] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][6] = {0.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[0][7] = {0.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[0][8] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][9] = {0.7/9.5, 1 - 3.4/9.5}

FONT_RANGE[1][0] = {2.0/9.5, 1 - 4.9/9.5}
FONT_RANGE[1][1] = {2.0/9.5, 1 - 4.7/9.5}
FONT_RANGE[1][2] = {2.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[1][3] = {2.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[1][4] = {2.0/9.5, 1 - 4.4/9.5}
FONT_RANGE[1][5] = {2.0/9.5, 1 - 4.4/9.5}
FONT_RANGE[1][6] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][7] = {2.0/9.5, 1 - 5.2/9.5}
FONT_RANGE[1][8] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][9] = {2.0/9.5, 1 - 4.7/9.5}

FONT_RANGE[2][0] = {1.5/9.5, 1 - 4.2/9.5}
FONT_RANGE[2][1] = {1.5/9.5, 1 - 4.0/9.5}
FONT_RANGE[2][2] = {1.5/9.5, 1 - 3.3/9.5}
FONT_RANGE[2][3] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][4] = {1.5/9.5, 1 - 4.0/9.5}
FONT_RANGE[2][5] = {1.5/9.5, 1 - 4.0/9.5}
FONT_RANGE[2][6] = {1.5/9.5, 1 - 3.8/9.5}
FONT_RANGE[2][7] = {1.5/9.5, 1 - 4.3/9.5}
FONT_RANGE[2][8] = {1.5/9.5, 1 - 3.9/9.5}
FONT_RANGE[2][9] = {1.5/9.5, 1 - 3.9/9.5}

FONT_RANGE[3][0] = {1.7/9.5, 1 - 4.2/9.5}
FONT_RANGE[3][1] = {1.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[3][2] = {1.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[3][3] = {1.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[3][4] = {1.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[3][5] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][6] = {1.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[3][7] = {1.7/9.5, 1 - 4.4/9.5}
FONT_RANGE[3][8] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][9] = {1.7/9.5, 1 - 3.8/9.5}

FONT_RANGE[4][0] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][1] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][2] = {1.0/9.5, 1 - 2.9/9.5}
FONT_RANGE[4][3] = {1.0/9.5, 1 - 3.2/9.5}
FONT_RANGE[4][4] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][5] = {1.0/9.5, 1 - 3.2/9.5}
FONT_RANGE[4][6] = {1.0/9.5, 1 - 3.2/9.5}
FONT_RANGE[4][7] = {1.0/9.5, 1 - 4.2/9.5}
FONT_RANGE[4][8] = {1.0/9.5, 1 - 3.3/9.5}
FONT_RANGE[4][9] = {1.0/9.5, 1 - 3.3/9.5}

FONT_RANGE[5][0] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][1] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][2] = {1.4/9.5, 1 - 3.1/9.5}
FONT_RANGE[5][3] = {1.4/9.5, 1 - 3.0/9.5}
FONT_RANGE[5][4] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][5] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][6] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][7] = {1.4/9.5, 1 - 4.2/9.5}
FONT_RANGE[5][8] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][9] = {1.4/9.5, 1 - 3.2/9.5}

FONT_RANGE[6][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[6][1] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[6][2] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][3] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][4] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][5] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][6] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][7] = {1.2/9.5, 1 - 4.2/9.5}
FONT_RANGE[6][8] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][9] = {1.2/9.5, 1 - 3.4/9.5}

FONT_RANGE[7][0] = {1.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[7][1] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][2] = {1.0/9.5, 1 - 3.8/9.5}
FONT_RANGE[7][3] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[7][4] = {1.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[7][5] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[7][6] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][7] = {1.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[7][8] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][9] = {1.0/9.5, 1 - 4.15/9.5}

FONT_RANGE[8][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[8][1] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][2] = {1.2/9.5, 1 - 3.1/9.5}
FONT_RANGE[8][3] = {1.2/9.5, 1 - 2.8/9.5}
FONT_RANGE[8][4] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[8][5] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[8][6] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][7] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[8][8] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][9] = {1.2/9.5, 1 - 3.5/9.5}

FONT_RANGE[9][0] = {1.1/9.5, 1 - 3.7/9.5}
FONT_RANGE[9][1] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][2] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][3] = {1.1/9.5, 1 - 2.8/9.5}
FONT_RANGE[9][4] = {1.1/9.5, 1 - 3.2/9.5}
FONT_RANGE[9][5] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][6] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][7] = {1.1/9.5, 1 - 4.0/9.5}
FONT_RANGE[9][8] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][9] = {1.1/9.5, 1 - 3.5/9.5}

local FONT_RANGE = {}
FONT_RANGES[FONT_ENMEY_DAMAGE] = FONT_RANGE

FONT_RANGE[0] = {}
FONT_RANGE[1] = {}
FONT_RANGE[2] = {}
FONT_RANGE[3] = {}
FONT_RANGE[4] = {}
FONT_RANGE[5] = {}
FONT_RANGE[6] = {}
FONT_RANGE[7] = {}
FONT_RANGE[8] = {}
FONT_RANGE[9] = {}

FONT_RANGE[0][0] = {0.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[0][1] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][2] = {0.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[0][3] = {0.7/9.5, 1 - 3.6/9.5}
FONT_RANGE[0][4] = {0.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[0][5] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][6] = {0.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[0][7] = {0.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[0][8] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][9] = {0.7/9.5, 1 - 3.4/9.5}

FONT_RANGE[1][0] = {2.0/9.5, 1 - 4.9/9.5}
FONT_RANGE[1][1] = {2.0/9.5, 1 - 4.7/9.5}
FONT_RANGE[1][2] = {2.0/9.5, 1 - 4.7/9.5}
FONT_RANGE[1][3] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][4] = {2.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[1][5] = {2.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[1][6] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][7] = {2.0/9.5, 1 - 5.2/9.5}
FONT_RANGE[1][8] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][9] = {2.0/9.5, 1 - 4.7/9.5}

FONT_RANGE[2][0] = {1.5/9.5, 1 - 3.6/9.5}
FONT_RANGE[2][1] = {1.5/9.5, 1 - 3.3/9.5}
FONT_RANGE[2][2] = {1.5/9.5, 1 - 3.3/9.5}
FONT_RANGE[2][3] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][4] = {1.5/9.5, 1 - 3.0/9.5}
FONT_RANGE[2][5] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][6] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][7] = {1.5/9.5, 1 - 3.6/9.5}
FONT_RANGE[2][8] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][9] = {1.5/9.5, 1 - 3.3/9.5}

FONT_RANGE[3][0] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][1] = {1.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[3][2] = {1.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[3][3] = {1.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[3][4] = {1.7/9.5, 1 - 2.9/9.5}
FONT_RANGE[3][5] = {1.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[3][6] = {1.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[3][7] = {1.7/9.5, 1 - 4.0/9.5}
FONT_RANGE[3][8] = {1.7/9.5, 1 - 3.2/9.5}
FONT_RANGE[3][9] = {1.7/9.5, 1 - 3.3/9.5}

FONT_RANGE[4][0] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[4][1] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][2] = {1.0/9.5, 1 - 3.8/9.5}
FONT_RANGE[4][3] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][4] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][5] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][6] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][7] = {1.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[4][8] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][9] = {1.0/9.5, 1 - 3.7/9.5}

FONT_RANGE[5][0] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][1] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][2] = {1.4/9.5, 1 - 3.1/9.5}
FONT_RANGE[5][3] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][4] = {1.4/9.5, 1 - 2.8/9.5}
FONT_RANGE[5][5] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][6] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][7] = {1.4/9.5, 1 - 4.2/9.5}
FONT_RANGE[5][8] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][9] = {1.4/9.5, 1 - 3.2/9.5}

FONT_RANGE[6][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[6][1] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[6][2] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][3] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][4] = {1.2/9.5, 1 - 2.6/9.5}
FONT_RANGE[6][5] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][6] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][7] = {1.2/9.5, 1 - 4.2/9.5}
FONT_RANGE[6][8] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][9] = {1.2/9.5, 1 - 3.2/9.5}

FONT_RANGE[7][0] = {1.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[7][1] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][2] = {1.0/9.5, 1 - 3.8/9.5}
FONT_RANGE[7][3] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][4] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][5] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[7][6] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][7] = {1.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[7][8] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][9] = {1.0/9.5, 1 - 4.15/9.5}

FONT_RANGE[8][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[8][1] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][2] = {1.2/9.5, 1 - 3.6/9.5}
FONT_RANGE[8][3] = {1.2/9.5, 1 - 3.3/9.5}
FONT_RANGE[8][4] = {1.2/9.5, 1 - 3.0/9.5}
FONT_RANGE[8][5] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][6] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][7] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[8][8] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][9] = {1.2/9.5, 1 - 3.5/9.5}

FONT_RANGE[9][0] = {1.1/9.5, 1 - 3.7/9.5}
FONT_RANGE[9][1] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][2] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][3] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][4] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][5] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][6] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][7] = {1.1/9.5, 1 - 4.0/9.5}
FONT_RANGE[9][8] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][9] = {1.1/9.5, 1 - 3.5/9.5}

local FONT_RANGE = {}
FONT_RANGES[FONT_ENMEY_DAMAGE_CRITICAL] = FONT_RANGE

FONT_RANGE[0] = {}
FONT_RANGE[1] = {}
FONT_RANGE[2] = {}
FONT_RANGE[3] = {}
FONT_RANGE[4] = {}
FONT_RANGE[5] = {}
FONT_RANGE[6] = {}
FONT_RANGE[7] = {}
FONT_RANGE[8] = {}
FONT_RANGE[9] = {}

FONT_RANGE[0][0] = {0.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[0][1] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][2] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][3] = {0.7/9.5, 1 - 3.1/9.5}
FONT_RANGE[0][4] = {0.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[0][5] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][6] = {0.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[0][7] = {0.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[0][8] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][9] = {0.7/9.5, 1 - 3.4/9.5}

FONT_RANGE[1][0] = {2.0/9.5, 1 - 4.9/9.5}
FONT_RANGE[1][1] = {2.0/9.5, 1 - 4.7/9.5}
FONT_RANGE[1][2] = {2.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[1][3] = {2.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[1][4] = {2.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[1][5] = {2.0/9.5, 1 - 4.4/9.5}
FONT_RANGE[1][6] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][7] = {2.0/9.5, 1 - 5.2/9.5}
FONT_RANGE[1][8] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][9] = {2.0/9.5, 1 - 4.7/9.5}

FONT_RANGE[2][0] = {1.5/9.5, 1 - 3.9/9.5}
FONT_RANGE[2][1] = {1.5/9.5, 1 - 3.7/9.5}
FONT_RANGE[2][2] = {1.5/9.5, 1 - 3.3/9.5}
FONT_RANGE[2][3] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][4] = {1.5/9.5, 1 - 3.0/9.5}
FONT_RANGE[2][5] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][6] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][7] = {1.5/9.5, 1 - 4.1/9.5}
FONT_RANGE[2][8] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][9] = {1.5/9.5, 1 - 3.3/9.5}

FONT_RANGE[3][0] = {1.7/9.5, 1 - 4.3/9.5}
FONT_RANGE[3][1] = {1.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[3][2] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][3] = {1.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[3][4] = {1.7/9.5, 1 - 3.2/9.5}
FONT_RANGE[3][5] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][6] = {1.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[3][7] = {1.7/9.5, 1 - 4.3/9.5}
FONT_RANGE[3][8] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][9] = {1.7/9.5, 1 - 3.9/9.5}

FONT_RANGE[4][0] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[4][1] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][2] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][3] = {1.0/9.5, 1 - 3.2/9.5}
FONT_RANGE[4][4] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][5] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][6] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][7] = {1.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[4][8] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][9] = {1.0/9.5, 1 - 3.7/9.5}

FONT_RANGE[5][0] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][1] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][2] = {1.4/9.5, 1 - 3.1/9.5}
FONT_RANGE[5][3] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][4] = {1.4/9.5, 1 - 3.0/9.5}
FONT_RANGE[5][5] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][6] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][7] = {1.4/9.5, 1 - 4.2/9.5}
FONT_RANGE[5][8] = {1.4/9.5, 1 - 3.4/9.5}
FONT_RANGE[5][9] = {1.4/9.5, 1 - 3.4/9.5}

FONT_RANGE[6][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[6][1] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[6][2] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][3] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][4] = {1.2/9.5, 1 - 2.8/9.5}
FONT_RANGE[6][5] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][6] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][7] = {1.2/9.5, 1 - 4.2/9.5}
FONT_RANGE[6][8] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][9] = {1.2/9.5, 1 - 3.4/9.5}

FONT_RANGE[7][0] = {1.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[7][1] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][2] = {1.0/9.5, 1 - 3.8/9.5}
FONT_RANGE[7][3] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[7][4] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][5] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[7][6] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][7] = {1.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[7][8] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][9] = {1.0/9.5, 1 - 4.15/9.5}

FONT_RANGE[8][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[8][1] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][2] = {1.2/9.5, 1 - 3.1/9.5}
FONT_RANGE[8][3] = {1.2/9.5, 1 - 2.8/9.5}
FONT_RANGE[8][4] = {1.2/9.5, 1 - 3.0/9.5}
FONT_RANGE[8][5] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[8][6] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][7] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[8][8] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][9] = {1.2/9.5, 1 - 3.5/9.5}

FONT_RANGE[9][0] = {1.1/9.5, 1 - 3.7/9.5}
FONT_RANGE[9][1] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][2] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][3] = {1.1/9.5, 1 - 2.8/9.5}
FONT_RANGE[9][4] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][5] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][6] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][7] = {1.1/9.5, 1 - 4.0/9.5}
FONT_RANGE[9][8] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][9] = {1.1/9.5, 1 - 3.5/9.5}

local FONT_RANGE = {}
FONT_RANGES[FONT_HERO_DAMAGE] = FONT_RANGE
FONT_RANGES[FONT_RAGE] = FONT_RANGE

FONT_RANGE[0] = {}
FONT_RANGE[1] = {}
FONT_RANGE[2] = {}
FONT_RANGE[3] = {}
FONT_RANGE[4] = {}
FONT_RANGE[5] = {}
FONT_RANGE[6] = {}
FONT_RANGE[7] = {}
FONT_RANGE[8] = {}
FONT_RANGE[9] = {}

FONT_RANGE[0][0] = {0.7/9.5, 1 - 3.8/9.5}
FONT_RANGE[0][1] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][2] = {0.7/9.5, 1 - 3.6/9.5}
FONT_RANGE[0][3] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][4] = {0.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[0][5] = {0.7/9.5, 1 - 3.6/9.5}
FONT_RANGE[0][6] = {0.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[0][7] = {0.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[0][8] = {0.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[0][9] = {0.7/9.5, 1 - 3.4/9.5}

FONT_RANGE[1][0] = {2.0/9.5, 1 - 4.9/9.5}
FONT_RANGE[1][1] = {2.0/9.5, 1 - 4.7/9.5}
FONT_RANGE[1][2] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][3] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][4] = {2.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[1][5] = {2.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[1][6] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][7] = {2.0/9.5, 1 - 5.2/9.5}
FONT_RANGE[1][8] = {2.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[1][9] = {2.0/9.5, 1 - 4.7/9.5}

FONT_RANGE[2][0] = {1.5/9.5, 1 - 3.9/9.5}
FONT_RANGE[2][1] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][2] = {1.5/9.5, 1 - 3.3/9.5}
FONT_RANGE[2][3] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][4] = {1.5/9.5, 1 - 3.0/9.5}
FONT_RANGE[2][5] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][6] = {1.5/9.5, 1 - 3.5/9.5}
FONT_RANGE[2][7] = {1.5/9.5, 1 - 3.8/9.5}
FONT_RANGE[2][8] = {1.5/9.5, 1 - 3.2/9.5}
FONT_RANGE[2][9] = {1.5/9.5, 1 - 3.3/9.5}

FONT_RANGE[3][0] = {1.7/9.5, 1 - 4.4/9.5}
FONT_RANGE[3][1] = {1.7/9.5, 1 - 4.1/9.5}
FONT_RANGE[3][2] = {1.7/9.5, 1 - 3.5/9.5}
FONT_RANGE[3][3] = {1.7/9.5, 1 - 3.3/9.5}
FONT_RANGE[3][4] = {1.7/9.5, 1 - 3.9/9.5}
FONT_RANGE[3][5] = {1.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[3][6] = {1.7/9.5, 1 - 3.4/9.5}
FONT_RANGE[3][7] = {1.7/9.5, 1 - 4.1/9.5}
FONT_RANGE[3][8] = {1.7/9.5, 1 - 3.7/9.5}
FONT_RANGE[3][9] = {1.7/9.5, 1 - 3.3/9.5}

FONT_RANGE[4][0] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[4][1] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][2] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][3] = {1.0/9.5, 1 - 3.4/9.5}
FONT_RANGE[4][4] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][5] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][6] = {1.0/9.5, 1 - 3.5/9.5}
FONT_RANGE[4][7] = {1.0/9.5, 1 - 4.5/9.5}
FONT_RANGE[4][8] = {1.0/9.5, 1 - 3.7/9.5}
FONT_RANGE[4][9] = {1.0/9.5, 1 - 3.7/9.5}

FONT_RANGE[5][0] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][1] = {1.4/9.5, 1 - 3.7/9.5}
FONT_RANGE[5][2] = {1.4/9.5, 1 - 3.1/9.5}
FONT_RANGE[5][3] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][4] = {1.4/9.5, 1 - 2.6/9.5}
FONT_RANGE[5][5] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][6] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][7] = {1.4/9.5, 1 - 4.2/9.5}
FONT_RANGE[5][8] = {1.4/9.5, 1 - 3.2/9.5}
FONT_RANGE[5][9] = {1.4/9.5, 1 - 3.2/9.5}

FONT_RANGE[6][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[6][1] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[6][2] = {1.2/9.5, 1 - 3.2/9.5}
FONT_RANGE[6][3] = {1.2/9.5, 1 - 3.6/9.5}
FONT_RANGE[6][4] = {1.2/9.5, 1 - 2.8/9.5}
FONT_RANGE[6][5] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][6] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][7] = {1.2/9.5, 1 - 4.2/9.5}
FONT_RANGE[6][8] = {1.2/9.5, 1 - 3.4/9.5}
FONT_RANGE[6][9] = {1.2/9.5, 1 - 3.4/9.5}

FONT_RANGE[7][0] = {1.0/9.5, 1 - 4.6/9.5}
FONT_RANGE[7][1] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][2] = {1.0/9.5, 1 - 3.8/9.5}
FONT_RANGE[7][3] = {1.0/9.5, 1 - 3.9/9.5}
FONT_RANGE[7][4] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][5] = {1.0/9.5, 1 - 4.1/9.5}
FONT_RANGE[7][6] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][7] = {1.0/9.5, 1 - 4.3/9.5}
FONT_RANGE[7][8] = {1.0/9.5, 1 - 4.0/9.5}
FONT_RANGE[7][9] = {1.0/9.5, 1 - 4.15/9.5}

FONT_RANGE[8][0] = {1.2/9.5, 1 - 3.8/9.5}
FONT_RANGE[8][1] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][2] = {1.2/9.5, 1 - 3.1/9.5}
FONT_RANGE[8][3] = {1.2/9.5, 1 - 3.3/9.5}
FONT_RANGE[8][4] = {1.2/9.5, 1 - 3.0/9.5}
FONT_RANGE[8][5] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][6] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][7] = {1.2/9.5, 1 - 4.0/9.5}
FONT_RANGE[8][8] = {1.2/9.5, 1 - 3.5/9.5}
FONT_RANGE[8][9] = {1.2/9.5, 1 - 3.5/9.5}

FONT_RANGE[9][0] = {1.1/9.5, 1 - 3.7/9.5}
FONT_RANGE[9][1] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][2] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][3] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][4] = {1.1/9.5, 1 - 3.0/9.5}
FONT_RANGE[9][5] = {1.1/9.5, 1 - 3.3/9.5}
FONT_RANGE[9][6] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][7] = {1.1/9.5, 1 - 4.0/9.5}
FONT_RANGE[9][8] = {1.1/9.5, 1 - 3.5/9.5}
FONT_RANGE[9][9] = {1.1/9.5, 1 - 3.5/9.5}

function QActorDamageView.createWithLabel(label, isHero, isDodge, isBlock, isCritical, isTreat, isAbsorb, isImmune, isRage, number, tipModifiers, isExecute)
	local view = label.damageView
	if view then
		view:removeFromParentAndCleanup(true)
	end

	local view = QActorDamageView.new()
	view:setDetail(label, isHero, isDodge, isBlock, isCritical, isTreat, isAbsorb, isImmune, isRage, number, false, tipModifiers, isExecute)
	label:getParent():addChild(view)
	label.damageView = view

    view:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(view, view._onFrame))
    view:scheduleUpdate_()
end

function QActorDamageView.clearLabel(label)
	local view = label.damageView
	if view then
		view:removeFromParentAndCleanup(true)
		label.damageView = nil
	end
end

function QActorDamageView:ctor()
	self:setCascadeOpacityEnabled(true)
end

function QActorDamageView:_onFrame()
	local label = self._label
	self:setScaleX(label:getScaleX() * 0.5)
	self:setScaleY(label:getScaleY() * 0.5)
	self:setPosition(ccp(label:getPosition()))
	self:setOpacity(label:getOpacity())
end

function QActorDamageView:setDetail(label, isHero, isDodge, isBlock, isCritical, isTreat, isAbsorb, isImmune, isRage, number, isString, tipModifiers, isExecute)
	self._label = label
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/battle_bumber_all.plist")

	local width = 0
	local sprite = nil
	local font = nil
	local font_range = nil
	local sprites = nil
	local charMods = nil
	local spriteWidth = nil
	local spriteRange = nil
	local mod = nil
	local sampleSpriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("shanbizi2.png")
	local node
	if sampleSpriteFrame and sampleSpriteFrame:getTexture() then
		node = CCSpriteBatchNode:createWithTexture(sampleSpriteFrame:getTexture())
	else
		node = display.newNode()
	end
	node:setCascadeOpacityEnabled(true)
	self:addChild(node)

	sprite = nil

	-- "斩杀" 字样
	if isExecute then
		sprite = CCSprite:createWithSpriteFrameName("zhansha.png")
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			sprite:setScale(1.6)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width

			number = 0 -- 不显示伤害
		end
	end

	-- "免疫"字符
	sprite = nil
	if isImmune then
		if isHero then
			sprite = CCSprite:createWithSpriteFrameName("mianyizi2.png")
		else
			sprite = CCSprite:createWithSpriteFrameName("mianyizi1.png")
		end
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "能量"字符
	sprite = nil
	if isRage then
		sprite = CCSprite:createWithSpriteFrameName("jishajiangli.png")
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(4)
			sprite:setPositionY(58)
			sprite:setScale(1.2)
			node:addChild(sprite)
		end
		sprite = CCSprite:createWithSpriteFrameName("nengliang1.png")
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "闪避"字符
	sprite = nil
	if isDodge then
		if isHero then
			sprite = CCSprite:createWithSpriteFrameName("shanbizi2.png")
		else
			sprite = CCSprite:createWithSpriteFrameName("shanbizi1.png")
		end
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "格挡"字符
	sprite = nil
	if isBlock then
		if isHero then
			sprite = CCSprite:createWithSpriteFrameName("gedangzi2.png")
		else
			sprite = CCSprite:createWithSpriteFrameName("gedangzi1.png")
		end
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "暴击"字符
	sprite = nil
	if isCritical then
		if isTreat then
			sprite = CCSprite:createWithSpriteFrameName("baojizi1.png")
		else
			if isHero then
				sprite = CCSprite:createWithSpriteFrameName("baojizi4.png")
			else
				sprite = CCSprite:createWithSpriteFrameName("baojizi3.png")
			end
		end
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "吸收"字符
	sprite = nil
	if isAbsorb then
		if isHero then
			sprite = CCSprite:createWithSpriteFrameName("xishou2.png")
		else
			sprite = CCSprite:createWithSpriteFrameName("xishou1.png")
		end
		if sprite then
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			sprite:setPositionX(width)
			node:addChild(sprite)
			width = width + sprite:getContentSize().width
		end
	end

	-- "+","-"字符
	sprite = nil
	if isTreat then
		sprite = CCSprite:createWithSpriteFrameName("fight_add.png")
	elseif isRage then
		if number > 0 then
			sprite = CCSprite:createWithSpriteFrameName("fight_add_b.png")
		else
			sprite = CCSprite:createWithSpriteFrameName("fight_jian_b.png")
		end
	else
		if number and (isString or number > 0) then
			-- if isHero then
			-- 	sprite = CCSprite:createWithSpriteFrameName("fight_jian_rr.png")
			-- else
			-- 	if isCritical then
			-- 		sprite = CCSprite:createWithSpriteFrameName("fight_jian.png")
			-- 	else
			-- 		sprite = CCSprite:createWithSpriteFrameName("fight_jian_y.png")
			-- 	end
			-- end
		end
	end
	if sprite then
		sprite:setCascadeOpacityEnabled(true)
		sprite:setAnchorPoint(ccp(0, 0.5))
		node:addChild(sprite)
		if isTreat then
			sprite:setPositionX(width - sprite:getContentSize().width * 0.1)
			width = width + sprite:getContentSize().width * 0.8
		else
			sprite:setPositionX(width - sprite:getContentSize().width * 0.2)
			width = width + sprite:getContentSize().width * 0.6
		end
	end

	-- 数字字符
	sprite = nil
	if number then
		if isTreat then
			font = FONT_TREAT
		elseif isRage then
			font = FONT_RAGE
		else
			if isHero then
				font = FONT_HERO_DAMAGE
			else
				if isCritical then
					font = FONT_ENMEY_DAMAGE_CRITICAL
				else
					font = FONT_ENMEY_DAMAGE
				end
			end
		end
		font_range = FONT_RANGES[font]

		sprites = {}
		charMods = {}
		if not isString then
			number = math.floor(math.abs(number))
			while number > 0 do
				mod = math.fmod(number, 10)
				number = (number - mod) / 10
				--sprite = CCSprite:createWithSpriteFrameName(font .. mod .. ".png")
				sprite = CCSprite:createWithSpriteFrameName( QResPath(font)[mod + 1] )
				if sprite then
					sprites[#sprites + 1] = sprite
					charMods[#charMods + 1] = mod
				end
			end
		else
			for i = string.len(number), 1, -1 do
				mod = tonumber(string.sub(number, i, i))
				--sprite = CCSprite:createWithSpriteFrameName(font .. mod .. ".png")
				sprite = CCSprite:createWithSpriteFrameName( QResPath(font)[mod + 1] )
				if sprite then
					sprites[#sprites + 1] = sprite
					charMods[#charMods + 1] = mod
				end
			end
		end
		for index = #sprites, 1, -1 do
			sprite = sprites[index]
			sprite:setCascadeOpacityEnabled(true)
			sprite:setAnchorPoint(ccp(0, 0.5))
			node:addChild(sprite)

			spriteRange = font_range[charMods[index]][charMods[index - 1] or 0]
			spriteWidth = sprite:getContentSize().width
			sprite:setPositionX(width - spriteWidth * spriteRange[1])
			width = width + spriteWidth * (spriteRange[2] - spriteRange[1])
		end
	end

	-- 浮动数字修饰词
	sprite = nil
	if tipModifiers and #tipModifiers then
		local modifierWidth = 0
		local modifierSprites = {}
		for _, tipModifier in ipairs(tipModifiers) do
			if tipModifier == "减伤" then
				if isHero then
					sprite = CCSprite:createWithSpriteFrameName("jianshang2.png")
				else
					sprite = CCSprite:createWithSpriteFrameName("jianshang1.png")
				end
			elseif tipModifier == "双倍" then
				if isTreat then
					sprite = CCSprite:createWithSpriteFrameName("shuangbei2.png")
				else
					if isHero then
						sprite = CCSprite:createWithSpriteFrameName("shuangbei3.png")
					else
						sprite = CCSprite:createWithSpriteFrameName("shuangbei1.png")
					end
				end
			elseif tipModifier == "反伤" then
				if isHero then
					sprite = CCSprite:createWithSpriteFrameName("fanshang2.png")
				else
					sprite = CCSprite:createWithSpriteFrameName("fanshang1.png")
				end
			elseif tipModifier == "真实伤害" then
				if isHero then
					sprite = CCSprite:createWithSpriteFrameName("zssh2.png")
				else
					sprite = CCSprite:createWithSpriteFrameName("zssh1.png")
				end
			elseif tipModifier == "吸血" then
				sprite = CCSprite:createWithSpriteFrameName("xixue2.png")
			elseif tipModifier == "无敌" then
				if isHero then
					sprite = CCSprite:createWithSpriteFrameName("wudi2.png")
				else
					sprite = CCSprite:createWithSpriteFrameName("wudi1.png")
				end
			end
			if sprite then
				sprite:setPositionY(58)
				sprite:setPositionX(modifierWidth)
				sprite:setAnchorPoint(ccp(0, 0.5))
				modifierWidth = modifierWidth + sprite:getContentSize().width
				modifierSprites[#modifierSprites + 1] = sprite
			end
			sprite = nil
		end
		for _, modifierSprite in ipairs(modifierSprites) do
			modifierSprite:setPositionX(modifierSprite:getPositionX() + (width - modifierWidth) * 0.5)
			node:addChild(modifierSprite)
		end
	end

	-- 暴击放大
	if isCritical then
		node:setScale(1.1)
		width = width * 1.1
	end

	-- 居中
	node:setPositionX(-width / 2)
end

return QActorDamageView