_G.RenderConfig = {}


_rd.blockQuality = 0.8      --透明质量
_rd.blockColor = 0x222356E8 --半透明遮挡时的颜色

--摄像机相关配置
RenderConfig.fWheelSpeed = 2.0          --滚轮速度
RenderConfig.cameraMinHeight = {
	[enProfType.eProfType_Sickle] = 5,
    [enProfType.eProfType_Sword] = 5,
    [enProfType.eProfType_Human] = 7,
    [enProfType.eProfType_Woman] = 5,
}
RenderConfig.cameraMaxHeight = 150
RenderConfig.eparam = 1.05

---遮挡
RenderConfig.isBlocker = true
RenderConfig.isBlockee = true

RenderConfig.isShowTerrain = true
RenderConfig.isDebugMe = false

---debug screen,
--_sys.showStat = false
RenderConfig.isDebugDrawBoard = false
RenderConfig.screenW = 1920
RenderConfig.screenH = 1080
if RenderConfig.isDebugDrawBoard then
    RenderConfig.screenDB = _DrawBoard.new(RenderConfig.screenW, RenderConfig.screenH);
end
RenderConfig.pfxSkl = _Skeleton.new();

--debug 9tile
RenderConfig.show9Tile = false;
--batch
RenderConfig.batch = true;
--debug wall for draw 正交摄像机下map
RenderConfig.showWall = false;
--debug scene render
RenderConfig.showScene = true;
