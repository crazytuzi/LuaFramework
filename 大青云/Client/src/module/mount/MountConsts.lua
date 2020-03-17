--[[
坐骑常量
zhangshuhui
2014年11月05日17:20:20
]]

_G.MountConsts = {};

------------坐骑面板标签页名称---------------
--坐骑
MountConsts.TABMOUNT = "TABMOUNT";
--坐骑皮肤
MountConsts.TABMOUNTSKIN = "TABMOUNTSKIN";
--灵兽坐骑
MountConsts.TABMOUNTLINGSHOU = "TABMOUNTLINGSHOU";
--坐骑首日运营活动
MountConsts.TAB_MountFirstDay = "TAB_MountFirstDay";


--坐骑升阶
MountConsts.MOUNTLVUP = "MOUNTLVUP";
--坐骑技能
MountConsts.MOUNTSKILL = "MOUNTSKILL";
--UI上技能总数
MountConsts.skillTotalNum=6

--显示分类
MountConsts.ShowType_SHOUHUI = 1;--收回
MountConsts.ShowType_GENSUI = 2;--跟随
MountConsts.ShowType_ZAIQI = 3;--再骑

--属性名
_G.enMountAttrTypeName = {
	[enAttrType.eaGongJi] = UIStrConfig['mount9'],
    [enAttrType.eaFangYu] = UIStrConfig['mount10'],
	[enAttrType.eaMaxHp]    = UIStrConfig['mount11'],
    [enAttrType.eaMingZhong] = UIStrConfig['mount12'],
    [enAttrType.eaShanBi]    = UIStrConfig['mount13'],
    [enAttrType.eaBaoJi]     = UIStrConfig['mount14'],
    [enAttrType.eaRenXing]   = UIStrConfig['mount15'],
	[enAttrType.eaMoveSpeed]    = UIStrConfig['mount16'],
}

--坐骑最高阶
MountConsts.MountLevelMax = #t_horse;
--MountConsts.MountLingShouLevelMax = MountUtil:GetMountLingShouMax();

--坐骑星级
MountConsts.MountStarMax = 5

--特殊坐骑id下限
MountConsts.SpecailDownid = 200

--灵兽坐骑id下限
MountConsts.LingShouSpecailDownid = 300

--坐骑1秒内不让上坐骑
MountConsts.RideMountTime = 2

--坐骑自动进阶间隔时间
MountConsts.ZiDongSpaceTime = 0.3

--进度条满后与清空的间隔时间
MountConsts.ProgressSpaceTime = 0.2

--坐骑展示时间
MountConsts.MountShowTime = 5000

--动作间隔时间 15秒
MountConsts.actionspacetime = 150;

--预览动作延迟时间0.5秒
MountConsts.previewplaytime = 5;

--打开面板延迟时间2秒
MountConsts.beforeplaytime = 20;

--灵力提示升星时间间隔
MountConsts.lingliuptimelast = 600;

--默认看见10阶坐骑皮肤
MountConsts.showmountmaxorder = 12;
--5阶才能看到11阶的
MountConsts.shownextmountmaxorder = 5;
--只显示当前阶+6的等阶坐骑
MountConsts.showmountmaxorderadd = 6;

MountConsts.MountEquipType = {
	BagConsts.Equip_H_AnJu,BagConsts.Equip_H_JiangSheng,BagConsts.Equip_H_TouShi,BagConsts.Equip_H_DengJu};