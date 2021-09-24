
--stepId=步骤ID ,clickRect=可点击区域,hasCloseBtn=是否有关闭按钮,hasPanle=是否有面板,panlePos=面板坐标,clickToNext=点击屏幕进入下一步？ arrowDirect=1:向下 2:向上 3:右上    delayTime 可以不配置，显示引导面板的延迟时间

i5_space=90
newGuidCfg={
    {stepId=1,clickRect=CCRectMake(170+160,270,200,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,570),clickToNext=false,arrowDirect=1,arrowPos=ccp(275+160,545),delayTime=0.2,toStepId=2},
    {stepId=2,clickRect=CCRectMake(405,306-175+i5_space,187,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,560-170+i5_space-15),delayTime=1,toStepId=3},
    {stepId=3,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=4},
    {stepId=4,clickRect=CCRectMake(170+160,270,200,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,570),clickToNext=false,arrowDirect=1,arrowPos=ccp(275+160,545),toStepId=5},
    {stepId=5,clickRect=CCRectMake(218,870+i5_space,202,105),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,280+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(320,640+80+i5_space),toStepId=6},
    {stepId=6,clickRect=CCRectMake(20,730+i5_space,600,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(320,600+i5_space-15),toStepId=7},
    {stepId=7,clickRect=CCRectMake(395,110-170+i5_space,187,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(490,340-170+i5_space+10),toStepId=8},
    {stepId=8,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,390),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=9},
    {stepId=9,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,832+i5_space),toStepId=10},
    {stepId=10,clickRect=CCRectMake(157,-3,130,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(223,295),toStepId=11},
    {stepId=11,clickRect=CCRectMake(20,580+i5_space,210,220),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,160+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(140,935+i5_space),delayTime=0.2,toStepId=12},
    {stepId=12,clickRect=CCRectMake(40,715+i5_space-140,150,122),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,260+i5_space-160),clickToNext=false,arrowDirect=1,arrowPos=ccp(120,1000+i5_space-15-160),toStepId=13},

    {stepId=13,clickRect=CCRectMake(226,29-88+i5_space,185,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,180+i5_space+10),toStepId=14},
    {stepId=14,clickRect=CCRectMake(426,29-88+i5_space,185,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(520,180+i5_space+10),delayTime=0.2,toStepId=15},
    {stepId=15,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),toStepId=16},
    {stepId=16,clickRect=CCRectMake(219,32,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,490-i5_space+60),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,430-i5_space-70),toStepId=19},
    {stepId=17,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,832+i5_space),toStepId=18},
    {stepId=18,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,832+i5_space),toStepId=19},
    

    {stepId=19,clickRect=CCRectMake(-5,-5,180,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(84,288),toStepId=20},
    {stepId=20,clickRect=CCRectMake(115+35,550+i5_space,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,150+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(216+35,795+i5_space),toStepId=21},
    {stepId=21,clickRect=CCRectMake(20,650+80+i5_space,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(330,480+100+i5_space),toStepId=22},
    {stepId=22,clickRect=CCRectMake(398,20+130+i5_space,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,270+130+i5_space),toStepId=23},
    {stepId=23,clickRect=CCRectMake(290+50,630+105,200,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=2,arrowPos=ccp(400+40,480+105),toStepId=24},
    {stepId=24,clickRect=CCRectMake(20,480+80+i5_space,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,100+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,795+80+i5_space),toStepId=25},
    {stepId=25,clickRect=CCRectMake(398,20+130+i5_space,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,270+130+i5_space),toStepId=26},
    {stepId=26,clickRect=CCRectMake(390+52,790,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200+105),clickToNext=false,arrowDirect=2,arrowPos=ccp(488+60,532+105),toStepId=27},
    {stepId=27,clickRect=CCRectMake(20,330+80+i5_space,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,600+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(330,182+80+i5_space),toStepId=28},
    {stepId=28,clickRect=CCRectMake(398,20+130+i5_space,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,270+130+i5_space),toStepId=30},
        {stepId=29,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=30},
    {stepId=30,clickRect=CCRectMake(310,345+i5_space,330,250),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(480,200+i5_space),toStepId=31},
    --修改stepId=31，此项clickRect或arrowPos时，newGuidMgr:showGuid()里也需要修改
    {stepId=31,clickRect=CCRectMake(0,670,80,90),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,280),clickToNext=false,arrowDirect=4,arrowPos=ccp(140,720),toStepId=32},


    {stepId=32,clickRect=CCRectMake(464+30,636+80+i5_space+5,150-40,100+25),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,180+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(540+10,882+80+i5_space+30),toStepId=33},
    {stepId=33,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),toStepId=34},
    {stepId=34,clickRect=CCRectMake(464+30,636+80+i5_space+5,150-40,100+25),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,180+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(540+10,882+80+i5_space+30),toStepId=35},
    {stepId=35,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752+80+i5_space),toStepId=36},
    

        {stepId=36,clickRect=CCRectMake(-5,860+i5_space*2,280,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250+i5_space*2),clickToNext=false,arrowDirect=2,arrowPos=ccp(150,713+i5_space*2),delayTime=0.2,toStepId=38},
    {stepId=37,clickRect=CCRectMake(-5,860+i5_space*2,370,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250+i5_space*2),clickToNext=false,arrowDirect=2,arrowPos=ccp(200,713+i5_space*2),delayTime=0.2,toStepId=38},
    {stepId=38,clickRect=CCRectMake(505,435+i5_space-40,110,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,550+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(550,58+80+i5_space-40),toStepId=39},
    {stepId=39,clickRect=CCRectMake(210,780+80+i5_space,220,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(325,630+80+i5_space),toStepId=40},
    -- {stepId=40,clickRect=CCRectMake(495,630+90+i5_space,110,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(550,493+80+i5_space),toStepId=41},
     {stepId=40,clickRect=CCRectMake(490,650+100+i5_space,110,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(550,493+80+i5_space),toStepId=41},

    {stepId=41,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752+80+i5_space),toStepId=43},
    {stepId=42,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752+80+i5_space),toStepId=43},
    {stepId=43,clickRect=CCRectMake(0,810+i5_space*2,640,60),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space*2),clickToNext=false,arrowDirect=2,arrowPos=ccp(480,663+i5_space*2),toStepId=44},
    {stepId=44,clickRect=CCRectMake(20,380+80+i5_space,600,160),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,660+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(332,230+80+i5_space),toStepId=45},
    {stepId=45,clickRect=CCRectMake(430,294+88+i5_space,180,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,560+i5_space),clickToNext=false,arrowDirect=2,arrowPos=ccp(520,86+140+i5_space),toStepId=48},
    {stepId=46,clickRect=CCRectMake(520,949+i5_space,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300+i5_space),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752+80+i5_space),toStepId=48},
        {stepId=47,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=48},
    {stepId=48,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=55},
        
        {stepId=49,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=50},
        {stepId=50,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=52},
        {stepId=51,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=52},
        {stepId=52,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=53},
        {stepId=53,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400+i5_space),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=3,toStepId=54},
        {stepId=54,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=55},
        {stepId=55,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400+i5_space),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=49},
   
}