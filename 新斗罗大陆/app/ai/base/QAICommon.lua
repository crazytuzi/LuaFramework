--[[
    Class name QAICommon 
    Create by julian 
    This class is a handle notification push stuff
--]]

local QAICommon = class("QAICommon")

-- condition name
QAICommon.CONDITION_ACTOR_STATE = "CONDITION_ACTOR_STATE" -- param: state

-- operator
QAICommon.OPERATOR_TRUE = "AI_OPERATOR_TRUE"
QAICommon.OPERATOR_FALSE = "AI_OPERATOR_FALSE"
QAICommon.OPERATOR_NOT = "AI_OPERATOR_NOT"
QAICommon.OPERATOR_AND = "AI_OPERATOR_AND"
QAICommon.OPERATOR_OR = "AI_OPERATOR_OR"

return QAICommon