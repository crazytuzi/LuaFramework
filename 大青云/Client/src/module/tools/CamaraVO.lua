_G.CamaraCfgVO = {}

-- Pos=3;look={996,-499,306};eye={939,-514,315};StrId=2;tm=0;last=3000;bCam=1;NpcPos=25;NpcId=20100008
CamaraCfgVO.cname =nil
CamaraCfgVO.pos = nil
CamaraCfgVO.look=nil
CamaraCfgVO.eye=nil
CamaraCfgVO.talkStr = nil
CamaraCfgVO.maxTime = nil
CamaraCfgVO.lastTime = nil
CamaraCfgVO.bCam = nil
CamaraCfgVO.playerMovePos = nil
CamaraCfgVO.npcId = nil
CamaraCfgVO.bIsShowUI = nil
CamaraCfgVO.NPCActCfg = nil
CamaraCfgVO.playerActId = nil
CamaraCfgVO.Patrol = nil
CamaraCfgVO.MyPatrol = nil
CamaraCfgVO.MonsterBorn = nil
CamaraCfgVO.sceneEffect = nil
CamaraCfgVO.shakeTime = nil
CamaraCfgVO.shakeMin = nil
CamaraCfgVO.shakeMax = nil
CamaraCfgVO.autoCamaraTaget = nil
CamaraCfgVO.bGotoNextByMoveTime = nil
CamaraCfgVO.FadeInTime = nil
CamaraCfgVO.FadeOutTime = nil
CamaraCfgVO.soundID = nil
CamaraCfgVO.bNext = nil
CamaraCfgVO.bIsHideMain = nil
CamaraCfgVO.bIsLock = nil
CamaraCfgVO.bResetDirect = nil
CamaraCfgVO.bShowNpc = nil
CamaraCfgVO.bGensuiShijiao = nil
CamaraCfgVO.cameraLookDif = nil
CamaraCfgVO.cameraRotateX = nil
CamaraCfgVO.cameraRotateY = nil
CamaraCfgVO.isResetRotate = nil
CamaraCfgVO.cameraDistanceSpeed = nil
CamaraCfgVO.isResetDistance = nil
function CamaraCfgVO:new()
	local obj = setmetatable({},{__index = self})
	return obj
end