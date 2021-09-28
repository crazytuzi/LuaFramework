
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 28, text = "@1",
            -- maxWidth = 600,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =0.4,
        },},
    {delay = {time = 0.8,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },








jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放

        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},

    },


qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },

    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1920, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map3",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "shiji.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj11","ll_22.png","1","-500","300","30","clip_1","0","-210","0"},},
    },
    {
        load = {tmpl = "modbj2",
            params = {"bj12","ui_effect_suanming","0.8","-480","280","28","clip_1","0","-180","0","0.5"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ybhui","hero_yangbuhui","-590","270","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"wxwen","hero_wuxiuwen","-650","250","0.11","clip_1","20"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"hsnv","hero_huangshannv","-480","430","0.04","clip_1","20"},},
    },





    {
        load = {tmpl = "modbj2",
            params = {"bj141","ui_effect_xiaonvwawa","1.2","-540","360","48","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"hbweng","hero_hebiweng","0","250","0.11","clip_1","20"},},
    },


    {
        load = {tmpl = "mod21",
            params = {"nmxing","hero_nimoxing","400","280","0.10","clip_1","20"},},
    },







    {
        load = {tmpl = "modbj1",
            params = {"bj21","ll_23.png","0.8","670","350","15","clip_1","0","0","0"},},
    },
    {
        load = {tmpl = "modbj2",
            params = {"bj22","ui_effect_datiege","0.8","480","380","10","clip_1","0","0","0","1"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj211","ll_22.png","1","620","300","30","clip_1","0","-210","0"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"zzliu","hero_zhuziliu","620","280","0.1","clip_1","20"},},
    },




    {
        load = {tmpl = "mod21",
            params = {"jlfwang","hero_jinlunfawang","700","-220","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"deba","hero_daerba","560","-240","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod21",
            params = {"hdu","hero_huodu","820","-230","0.16","clip_1","90"},},
    },


    {
        load = {tmpl = "mod21",
            params = {"gfu","hero_guofu","320","-240","0.16","clip_1","90"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"gplu","hero_guopolu","220","-240","0.16","clip_1","90"},},
    },






    {
        load = {tmpl = "modbj1",
            params = {"bj31","ll_15.png","0.7","-150","-180","95","clip_1","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj35","ui_effect_chifan_a","1","50","360","98","bj31","0","0","0","1"},},
    },

    -- {
    --     load = {tmpl = "modbj2",
    --         params = {"bj37","ui_effect_hejiu","1","-150","0","48","bj31","0","0","0","1"},},
    -- },

    {
        load = {tmpl = "modbj2",
            params = {"bj36","ui_effect_chifan_b","1","100","400","-94","bj31","0","0","0","1"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj32","ll_16.png","1","20","-310","-80","bj35","0","0","0"},},
    },

    {
        load = {tmpl = "modbj1",
            params = {"bj33","ll_17.png","1","150","-270","-93","bj36","0","0","0"},},
    },




    {
        load = {tmpl = "modbj1",
            params = {"bj41","ll_14.png","0.6","-550","-180","95","clip_1","0","0","0"},},
    },
    {
        load = {tmpl = "modbj1",
            params = {"bj411","ll_14.png","0.7","0","70","-95","bj41","0","0","0"},},
    },
	{
        load = {tmpl = "modbj1",
            params = {"bj42","ll_21.png","0.7","0","150","500","bj41","0","0","0"},},
    },

    {
        load = {tmpl = "modbj2",
            params = {"bj37","ui_effect_hejiu","1","150","-10","48","bj41","0","0","0","0.5"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"zcong","hero_zhucong","-350","-270","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lyjiao","hero_luyoujiao","-700","-230","0.16","clip_1","90"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"ydtian","hero_yangdingtian","-1050","-220","0.16","clip_1","90"},},
    },


    {   model = {
            tag  = "zslwang1",     type  = DEF.FIGURE,
            pos= cc.p(-860,-220),    order     = 90,
            file = "hero_zishanlongwang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.3,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "zslwang2",     type  = DEF.FIGURE,
            pos= cc.p(-910,-225),    order     = 95,
            file = "hero_zishanlongwang",    animation = "yun",
            scale = 0.142,   parent = "clip_1", speed = 0.05,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},



    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-720","0","0.15","clip_1","50"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"lwshuang","hero_luwushuang","-560","0","0.15","clip_1","50"},},
    },





    -- {action = {tag  = "lwshuang",sync = false,what = {loop = {sequence = {{rotate =
    --              {to  = cc.vec3(0,-200,0),time = 1, },},
    --         {rotate = {to= cc.vec3(0,-160,0),time = 1,},},},},},},},





     {
         load = {tmpl = "jt",
             params = {"clip_1","0","0.7","-350","0"},},
     },







    -- {
    --     load = {tmpl = "mod21",
    --         params = {"zjue","_lead_","0","-80","0.16","clip_1"},},
    -- },




    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },



	{
        music = {file = "jianghu2.mp3",},
    },


----正式剧情


    {
        delay = {time = 0.1,},
    },
     {
         load = {tmpl = "jt",
             params = {"clip_1","2","0.7","700","0"},},
     },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.5","1","280","50"},},
     },





    {
        delay = {time = 0.1,},
    },






    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("我说陆姑娘，你还真是个惹祸精，这边刚打发了全真教，那边又来了丐帮……"),47},},
     },

     {
         load = {tmpl = "move2",
             params = {"lws","lws.png",TR("陆无双")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lws",TR("哼！谁稀罕你帮忙了！"),206},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("得！是我多管闲事，我走——！行了吧！"),48},},
     },

    {
        delay = {time = 0.3,},
    },

    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","-720","0","0.15","clip_1","50"},},
    },

     {
         load = {tmpl = "talk",
             params = {"lws",TR("哎！等等！你刚才不是说……有办法能够让我的腿……"),207},},
     },

    {
        delay = {time = 0.3,},
    },


    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-720","0","0.15","clip_1","50"},},
    },






     {
         load = {tmpl = "talk",
             params = {"zj",TR("唉！今天无缘无故和别人斗了好几场，我这腰骨都快散架了……"),49},},
     },



     {
         load = {tmpl = "talk",
             params = {"lws",TR("啊——！要不……我帮你捏一捏……"),208},},
     },


    {
        load = {tmpl = "out3",
            params = {"zj","lws"},},
    },


    {remove = { model = {"lwshuang", }, },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-560,0),    order     = 45,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 0.5,by = cc.p(-160,60),},},},},

    {remove = { model = {"lwshuang", }, },},
    {
        load = {tmpl = "mod22",
            params = {"lwshuang","hero_luwushuang","-750","60","0.15","clip_1","45"},},
    },

    {delay={time=0.2},},


    {
        load = {tmpl = "mod21",
            params = {"lbyi","hero_nvzhu","-200","0","0.15","clip_1","50"},},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


     {
         load = {tmpl = "jptby",
             params = {"lbyi","0.4","-340","0","1","100"},},
     },



    {remove = { model = {"lwshuang", }, },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-750,60),    order     = 45,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=-1, rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 0.4,by = cc.p(-100,-20),},},},},

    {remove = { model = {"lwshuang", }, },},
    {
        load = {tmpl = "mod22",
            params = {"lwshuang","hero_luwushuang","-850","40","0.15","clip_1","45"},},
    },






     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("不用了，他的贱骨头，我会好好替他松一松！"),209},},
     },



     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("啊！——师父——我——我没有偷懒——"),50},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("让你打听小龙女的下落，你却在这里拈花惹草，看来是该给你松松筋骨了！"),210},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0.3","1","100","0"},},
     },




     {
         load = {tmpl = "move1",
             params = {"lws","lws.png",TR("陆无双")},},
     },
     {
         load = {tmpl = "talk1",
             params = {"lws",TR("喂--！"),211},},
     },


    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","-720","0","0.15","clip_1","50"},},
    },

     {
         load = {tmpl = "talk2",
             params = {"lws",TR("……你到底要怎么样才肯告诉我方法……要不……我用师父的五毒秘传和你换……"),212},},
     },
     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },


     {
         load = {tmpl = "talk",
             params = {"zj",TR("五毒秘传？——我可不稀罕……"),51},},
     },

    {
        load = {tmpl = "out3",
            params = {"lws","zj"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lmchou","hero_limochou","-1450","20","0.15","clip_1","45"},},
    },



     {
         load = {tmpl = "jt",
             params = {"clip_1","0.6","1","400","0"},},
     },


	{
        music = {file = "battle1.mp3",},
    },


    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(-1450,20),    order     = 45,
            file = "hero_limochou",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "lmchou",sync = false,what = {move = {
                   time = 1.5,by = cc.p(350,0),},},},},


    {delay={time=0.5},},

     {
         load = {tmpl = "jt",
             params = {"clip_1","1","1","-200","0"},},
     },


    {remove = { model = {"lmchou", }, },},
    {
        load = {tmpl = "mod22",
            params = {"lmchou","hero_limochou","-1100","20","0.15","clip_1","45"},},
    },



     {
         load = {tmpl = "move1",
             params = {"lmc","lmc.png",TR("李莫愁")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lmc",TR("哦！？我的五毒秘传什么时候变得这么不值钱了！"),213},},
     },



    {remove = { model = {"lwshuang", }, },},
    {
        load = {tmpl = "mod21",
            params = {"lwshuang","hero_luwushuang","-850","40","0.15","clip_1","45"},},
    },



     {
         load = {tmpl = "move2",
             params = {"lws","lws.png",TR("陆无双")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lws",TR("李莫愁！！！"),214},},
     },

     {
         load = {tmpl = "talk",
             params = {"lmc",TR("哼！逆徒，居然骗我说秘笈被丐帮抢走了！看我怎么收拾你！"),215},},
     },


    {
        load = {tmpl = "out2",
            params = {"lws"},},
    },

    {remove = { model = {"lwshuang", }, },},
    -- {
    --     load = {tmpl = "mod21",
    --         params = {"lwshuang","hero_luwushuang","-850","40","0.15","clip_1","45"},},
    -- },

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-850,40),    order     = 45,
            file = "hero_luwushuang",    animation = "win",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {delay={time=0.3},},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 0.1,by = cc.p(60,240),},},},},

    {remove = { model = {"lwshuang", }, },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-790,280),    order     = 45,
            file = "hero_luwushuang",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 0.3,by = cc.p(360,30),},},},},
    {remove = { model = {"lwshuang", }, },},

    -- {
    --     load = {tmpl = "mod22",
    --         params = {"lwshuang","hero_luwushuang","-850","40","0.15","clip_1","45"},},
    -- },

     {
         load = {tmpl = "talk",
             params = {"lmc",TR("小贱人，你还想逃！"),216},},
     },

    {
        load = {tmpl = "out1",
            params = {"lmc"},},
    },


    {remove = { model = {"lwshuang", }, },},
    -- {
    --     load = {tmpl = "mod21",
    --         params = {"lwshuang","hero_luwushuang","-850","40","0.15","clip_1","45"},},
    -- },

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(-1100,20),    order     = 45,
            file = "hero_limochou",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {delay={time=0.12},},

        {action = { tag  = "lmchou",sync = true,what = {move = {
                   time = 0.12,by = cc.p(50,240),},},},},

    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(-1050,280),    order     = 45,
            file = "hero_limochou",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,-30),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


        {action = { tag  = "lmchou",sync = true,what = {move = {
                   time = 0.3,by = cc.p(460,30),},},},},
    {remove = { model = {"lmchou", }, },},


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.6","1","-200","0"},},
     },


    {remove = { model = {"zjue", }, },},
    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-720","0","0.15","clip_1","50"},},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父，李莫愁心狠手辣，陆姑娘落在她的手上肯定凶多吉少！"),52},},
     },

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },


     {
         load = {tmpl = "talk",
             params = {"lby",TR("陆姑娘？哼！她的死活，与我何干！还不快跟我离开这里！"),217},},
     },



     {
         load = {tmpl = "talk",
             params = {"zj",TR("可是——！"),53},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },


    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(-200,360),    order     = 55,
            file = "hero_limochou",    animation = "nuji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},


    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(200,300),    order     = 45,
            file = "hero_luwushuang",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},



    {
        sound = {file = "hero_limochou_nuji.mp3",sync=false,},
    },

    {
       delay = {time = 0.5,},
    },

    {
        model = {
            tag = "lmchou",
            speed = 1.5,
        },
    },

     {
         load = {tmpl = "jttb",
             params = {"clip_1","0.5","0.8","-600","0"},},
     },

    {
       delay = {time = 0.5,},
    },



     {
         load = {tmpl = "jttb",
             params = {"clip_1","0.8","0.8","-400","0"},},
     },

        {action = { tag  = "lmchou",sync = false,what = {move = {
                   time = 0.8,by = cc.p(400,-150),},},},},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 0.8,by = cc.p(400,-150),},},},},

        {action = { tag  = "lmchou",sync = false,what = {move = {
                   time = 0.5,by = cc.p(60,-160),},},},},

    {remove = { model = {"lwshuang", }, },},







    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(600,150),    order     = 45,
            file = "hero_luwushuang",    animation = "aida",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "lwshuang",sync = false,what = {move = {
                   time = 0.5,by = cc.p(60,-100),},},},},
    {
       delay = {time = 0.2,},
    },
    {
        sound = {file = 218,sync=false,},
    },
    {
       delay = {time = 0.3,},
    },

    {remove = { model = {"lwshuang", }, },},

    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(200,50),    order     = 55,
            file = "hero_limochou",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.4, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(600,50),    order     = 45,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=400, rotation3D=cc.vec3(0,180,0),
        },},
    {
       delay = {time = 0.1,},
    },

    {
        model = {
            tag = "lwshuang",
            speed = -0.3,
        },
    },







     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.5","0.8","-400","0"},},
     },


        {action = { tag  = "lmchou",sync = false,what = {move = {
                   time = 1.5,by = cc.p(400,0),},},},},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 1.5,by = cc.p(400,0),},},},},

    {remove = { model = {"lwshuang", }, },},

    {remove = { model = {"lmchou", }, },},

    {   model = {
            tag  = "lmchou",     type  = DEF.FIGURE,
            pos= cc.p(600,50),    order     = 55,
            file = "hero_limochou",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(1000,50),    order     = 45,
            file = "hero_luwushuang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"lmc","lmc.png",TR("李莫愁")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lmc",TR("贱人！明年的今天就是你的忌日！"),219},},
     },


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.5","3","-2300","-400"},},
     },



    {
        load = {tmpl = "move2",
            params = {"lws","lws.png",TR("陆无双")},},
    },
     {
         load = {tmpl = "talk1",
             params = {"lws",TR("难道——我今天就要死在这里了吗！"),220},},
     },

     {
         load = {tmpl = "talk2",
             params = {"lws",TR("……傻蛋！你在哪里……快救救我……"),221},},
     },


    {
        load = {tmpl = "out3",
            params = {"lmc","lws"},},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.5","1","3600","400"},},
     },



     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父！这样下去，陆姑娘真的会没命的！你救救她吧！"),54},},
     },

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("…………"),222},},
     },


     {
         load = {tmpl = "talk",
             params = {"zj",TR("你不救！我救！"),55},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.3","1","-100","0"},},
     },





    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-720,0),    order     = 55,
            file = "_lead_",    animation = "win",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    -- {
    --    delay = {time = 0.1,},
    -- },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


        {action = { tag  = "zjue",sync = true,what = {move = {
                   time = 0.1,by = cc.p(30,200),},},},},

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-690,200),    order     = 45,
            file = "_lead_",    animation = "pose",
            scale = 0.15,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.25,to = 0.15,},},
    {bezier = {time = 0.25,to = cc.p(200,200),
                                 control={cc.p(-660,200),cc.p(-400,500),}
    },},},
    },},},

    {remove = { model = {"lbyi", }, },},
    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","-540","0","0.15","clip_1","50"},},
    },


     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("啊——你——！"),223},},
     },

    {
        load = {tmpl = "out1",
            params = {"lby"},},
    },

    {
       delay = {time = 0.2,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
