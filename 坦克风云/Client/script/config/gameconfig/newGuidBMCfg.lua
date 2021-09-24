
--stepId=步骤ID ,clickRect=可点击区域,hasCloseBtn=是否有关闭按钮,hasPanle=是否有面板,panlePos=面板坐标,clickToNext=点击屏幕进入下一步？ arrowDirect=1:向下 2:向上 3:右上    delayTime 可以不配置，显示引导面板的延迟时间

newGuidBMCfg={
    {stepId=1,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=2},
    {stepId=2,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=3},
    {stepId=3,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,570),clickToNext=false,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=4},
    {stepId=4,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=3,toStepId=5},
    {stepId=5,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=6},
    {stepId=6,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,5535),delayTime=0.2,toStepId=7},
    {stepId=7,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,5535),delayTime=0.2,toStepId=8},
    {stepId=8,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,570),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=9},
    {stepId=9,clickRect=CCRectMake(0,493,80,90),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,600),clickToNext=true,arrowDirect=4,arrowPos=ccp(155,535),delayTime=0.2,toStepId=nil},
    {stepId=10,clickRect=CCRectMake(170,240,200,150),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,600),clickToNext=true,arrowDirect=1,arrowPos=ccp(275,535),delayTime=0.2,toStepId=nil},
    {stepId=11,clickRect=CCRectMake(300,660,170,100),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,200),clickToNext=true,arrowDirect=2,arrowPos=ccp(385,535),delayTime=0.2,toStepId=12},
    {stepId=12,clickRect=CCRectMake(300,660,170,100),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,200),clickToNext=true,arrowDirect=2,arrowPos=ccp(385,535),delayTime=0.2,toStepId=nil},
    {stepId=13,clickRect=CCRectMake(157,-3,130,150),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,500),clickToNext=true,arrowDirect=1,arrowPos=ccp(223,295),delayTime=0.2,toStepId=nil},
    {stepId=14,clickRect=CCRectMake(-5,860,370,100),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,250),clickToNext=true,arrowDirect=2,arrowPos=ccp(200,713),delayTime=0.2,toStepId=nil},
    {stepId=15,clickRect=CCRectMake(495,300,110,110),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,600),clickToNext=true,arrowDirect=1,arrowPos=ccp(550,545),delayTime=0.2,toStepId=nil},
    {stepId=16,clickRect=CCRectMake(-5,860,370,100),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,250),clickToNext=true,arrowDirect=2,arrowPos=ccp(200,713),delayTime=0.2,toStepId=nil},
    {stepId=17,clickRect=CCRectMake(495,630,110,110),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,100),clickToNext=true,arrowDirect=2,arrowPos=ccp(550,505),delayTime=0.2,toStepId=nil},
    {stepId=18,clickRect=CCRectMake(220,210,200,180),hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,600),clickToNext=true,arrowDirect=1,arrowPos=ccp(325,535),delayTime=0.2,toStepId=nil},
   
}