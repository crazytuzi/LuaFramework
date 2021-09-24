
--stepId=步骤ID ,clickRect=可点击区域,hasCloseBtn=是否有关闭按钮,hasPanle=是否有面板,panlePos=面板坐标,clickToNext=点击屏幕进入下一步？ arrowDirect=1:向下 2:向上 3:右上    delayTime 可以不配置，显示引导面板的延迟时间
accessoryGuidCfg={
    {stepId=1,clickRect=CCRectMake(430,G_VisibleSizeHeight-360,180,90),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,G_VisibleSizeHeight-700),clickToNext=false,arrowDirect=2,arrowPos=ccp(520,G_VisibleSizeHeight-500),delayTime=0.2,toStepId=2},
    {stepId=2,clickRect=CCRectMake(515,G_VisibleSizeHeight-270,90,90),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,G_VisibleSizeHeight-600),clickToNext=false,arrowDirect=2,arrowPos=ccp(560,G_VisibleSizeHeight-425),delayTime=0.2,toStepId=3},
}