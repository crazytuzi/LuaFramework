
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
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@2", },},
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
            color  = cc.c3b(244, 217, 174),
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
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =0.4,
        },},
    {delay = {time = 0.8,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
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
            pos= cc.p("@3","@4"),  order     = -50,
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = -60,
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
            pos = cc.p(0, -50),
        },
    },


    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 0.9,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },


    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","150","-100","0.16","clip_1"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","0","-100","0.16","clip_1"},},
    },

     {
         load = {tmpl = "jt",
             params = {"clip_1","0","1","400","0"},},
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


----正式剧情



	{
        music = {file = "jianghu1.mp3",},
    },





    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-800,-100),    order     = 49,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.16,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "yguo",sync = false,what = {move = {
                   time = 1.5,by = cc.p(500,0),},},},},

    {delay={time=0.3},},

     {
         load = {tmpl = "jt",
             params = {"clip_1","1.2","1","-300","0"},},
     },

    {remove = { model = {"yguo", }, },},

    {
        load = {tmpl = "mod22",
            params = {"yguo","hero_yangguo_hei","-300","-100","0.16","clip_1"},},
    },






	{
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("你们是什么人？我姑姑呢！？"),160},},
     },

    {
        load = {tmpl = "out1",
            params = {"yg"},},
    },

    {remove = { model = {"lbyi", }, },},

    {
        load = {tmpl = "mod21",
            params = {"lbyi","hero_nvzhu","0","-100","0.16","clip_1"},},
    },



     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("嗯！？"),161},},
     },





    -- {   model = {
    --         tag  = "qinggong",     type  = DEF.FIGURE,
    --         pos= cc.p(0,-100),    order     = 50,
    --         file = "hero_nvzhu",    animation = "pugong",
    --         scale = 0.16,   parent = "clip_1",
    --         loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
    --     },},

    -- {action = {tag  = "lbyi", sync = true,what = {fadeout = {time = 0,},},},},


    -- {
    --    delay = {time = 0.3,},
    -- },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

     {
         load = {tmpl = "jptby",
             params = {"zjue","0.3","-300","0","1","60"},},
     },


    {remove = { model = {"zjue", }, },},

    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-150","-100","0.16","clip_1"},},
    },


    -- {
    --    delay = {time = 0.3,},
    -- },



    -- {
    --     model = {
    --         tag = "qinggong",
    --         speed = -1,
    --     },
    -- },

    -- {
    --    delay = {time = 0.8,},
    -- },

    -- {remove = { model = {"qinggong", }, },},

    -- {action = {tag  = "lbyi", sync = true,what = {fadein = {time = 0,},},},},





-- --洛白衣发招到一般，被主角打断



     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父，还是我来说吧，你那把剑又没长嘴，讲不清道理的！"),26},},
     },

    {
        load = {tmpl = "out2",
            params = {"lby"},},
    },


-- --主角移动到杨过身前


    {remove = { model = {"zjue", }, },},

    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","-150","-100","0.16","clip_1"},},
    },



     {
         load = {tmpl = "talk",
             params = {"zj",TR("杨过，你终于来了！？"),27},},
     },

     {
         load = {tmpl = "move2",
             params = {"yg","yg.png",TR("杨过")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("你们究竟是谁？"),162},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("杨过啊杨过！何必在意我们是谁呢……"),28},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("我只问你，龙姑娘待你如何，在你被全真教驱逐，又是谁救的你，收留你，教你武功？"),29},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("——是姑姑！救我，收留我，教我武功……"),163},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","yg"},},
    },






-- --画面切换为回忆界面，小龙女在全真手中救下杨过，杨过拜师，小龙女授武，小龙女受伤……

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },


     {
         load = {tmpl = "zm",
             params = {TR("杨过在重阳宫备受欺凌"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("好心的孙婆婆收留他，却不想……"),"840"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("被重阳宫围攻，两人都危在旦夕"),"780"},},
     },


    {delay = {time = 0.6,},},
    {remove = { model = {"900", "840", "780", }, },},





    {
        model = {
            type = DEF.CC,
            tag = "clip_2",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -50),
        },
    },





    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -90,
            file  = "guiyun.jpg",
            parent= "clip_2",
            rotation3D=cc.vec3(0,0,0),
        },
    },


    {
        load = {tmpl = "mod21",
            params = {"yzping","hero_yinzhiping","400","50","0.11","clip_2"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"zzjing","hero_zhaozhijing","300","-100","0.12","clip_2"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"qcji","hero_qiuchuji","400","-250","0.12","clip_2"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"ylting1","hero_yinliting","500","0","0.12","clip_2"},},
    },

    {
        load = {tmpl = "mod21",
            params = {"ylting2","hero_yinliting","500","-200","0.12","clip_2"},},
    },



    -- {   model = {
    --         tag  = "yguo1",     type  = DEF.FIGURE,
    --         pos= cc.p(-350,-100),    order   = 49,
    --         file = "hero_yangguo_hei",    animation = "aida",
    --         scale = 0.12,   parent = "clip_2", speed = 0.1,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},

    {   model = {
            tag  = "yguo1",     type  = DEF.FIGURE,
            pos= cc.p(-360,-80),    order   = 49,
            file = "hero_yangguo_hei",    animation = "shoushang",
            scale = 0.12,   parent = "clip_2", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    -- {   model = {
    --         tag  = "spp",     type  = DEF.PIC,
    --         pos= cc.p(-250,-20),    order   = 49,
    --         file = "hero_zhoudian",    animation = "nuji",
    --         scale = 0.11,   parent = "clip_2", speed = 6,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,-90),
    --     },},


    {
        model = {
            tag   = "spp",
            type  = DEF.PIC,
            scale = 0.22,
            pos   = cc.p(-350, -40),
            order = 60,
            file  = "spp.png",
            parent= "clip_2",
            rotation3D=cc.vec3(0,0,-40),
        },
    },




    -- {delay={time=0.26},},


    -- {
    --     model = {
    --         tag = "yguo1",
    --         speed = 0,
    --     },
    -- },

    -- {delay={time=0.15},},

    -- {
    --     model = {
    --         tag = "spp",
    --         speed = 0,
    --     },
    -- },


        {action = {tag  = "clip_2",what = {spawn = {{move = {time = 1.2,by = cc.p(300, 0),},},
             {scale= {time = 1.2,to = 1,},},},},},},



    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


	{
        music = {file = "jq_jy2.mp3",},
    },



    {
        model = {
            tag   = "map0",
            type  = DEF.PIC,
            scale = 3,
            pos   = cc.p(0, 0),
            order = 100,
            file  = "bj.png",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },



    {delay={time=0.6},},


     {
         load = {tmpl = "jt",
             params = {"clip_2","0.8","1","-600","0"},},
     },

     {
         load = {tmpl = "move2",
             params = {"zzj","zzj.png",TR("赵志敬")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zzj",TR("杨过，今日我就要清理门户了！"),164},},
     },

    {
        load = {tmpl = "out2",
            params = {"zzj"},},
    },








    -- {remove = { model = {"zzjing", }, },},
    -- {
    --     load = {tmpl = "mod22",
    --         params = {"zzjing","hero_zhaozhijing","300","-100","0.12","clip_2"},},
    -- },
    --     {delay = {time = 0.4,},},

    -- {remove = { model = {"zzjing", }, },},
    -- {
    --     load = {tmpl = "mod21",
    --         params = {"zzjing","hero_zhaozhijing","300","-100","0.12","clip_2"},},
    -- },

    -- {
    --     music = {file = "jq_bgm4.mp3",},
    -- },

     {
         load = {tmpl = "jt",
             params = {"clip_2","1.2","0.9","700","-200"},},
     },

        {delay = {time = 0.2,},},
     {
         load = {tmpl = "jt",
             params = {"clip_2","0.9","3","1200","-1200"},},
     },



     {
         load = {tmpl = "jttb",
             params = {"clip_2","2","3","0","500"},},
     },


     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_2","0.6","0.5","400","-100"},},
     -- },








    {   model = {
            tag  = "xlnv1",     type  = DEF.FIGURE,
            pos= cc.p(-600,550),    order     = 50,
            file = "hero_xiaolongnv",    animation = "win",
            scale = 0,   parent = "clip_2",opacity=0,
            loop = true,   endRlease = false,  speed=0.81, rotation3D=cc.vec3(0,0,15),
        },},



    {   model = {
            tag  = "xlnv2",     type  = DEF.FIGURE,
            pos= cc.p(-600,550),    order     = 50,
            file = "hero_xiaolongnv",    animation = "pose",
            scale = 0,   parent = "clip_2",opacity=0,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {action = {tag  = "xlnv1",sync = false,what ={ spawn={{scale= {time = 2,to = 0.12,},},
    {bezier = {time = 4,to = cc.p(-100,0),
                                 control={cc.p(-400,300),cc.p(-800,200),}
    },},},
    },},},

    {action = {tag  = "xlnv2",sync = false,what ={ spawn={{scale= {time = 2,to = 0.12,},},
    {bezier = {time = 4,to = cc.p(-100,0),
                                 control={cc.p(-400,300),cc.p(-800,200),}
    },},},
    },},},

    {action = {tag  = "xlnv2", sync = true,what = {fadein = {time = 0,},},},},




    {delay = {time = 2,},},


     {
         load = {tmpl = "jttb",
             params = {"clip_2","2.2","3","-1200","500"},},
     },


    {action = {tag  = "xlnv2", sync = true,what = {fadeout = {time = 0,},},},},

    {action = {tag  = "xlnv1", sync = true,what = {fadein = {time = 0,},},},},



    {delay = {time = 0.8,},},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {delay = {time = 1.2,},},




    {remove = { model = {"xlnv1", "xlnv2",}, },},
    {
        load = {tmpl = "mod22",
            params = {"xlnv","hero_xiaolongnv","-100","0","0.12","clip_2"},},
    },



     {
         load = {tmpl = "jt",
             params = {"clip_2","0.8","6","200","-400"},},
     },
     {
         load = {tmpl = "talkzm",
             params = {TR("一群男人欺负两个老弱妇孺！"),165},},
     },

     {
         load = {tmpl = "talkzm",
             params = {TR("全真教真是英雄，真是好汉！"),166},},
     },


    -- {delay = {time = 2,},},

     {
         load = {tmpl = "jt",
             params = {"clip_2","1","1","-300","800"},},
     },









    -- {remove = { model = {"xlnv", }, },},

    -- {   model = {
    --         tag  = "xlnv",     type  = DEF.FIGURE,
    --         pos= cc.p(-200,120),    order     = 50,
    --         file = "hero_xiaolongnv",    animation = "zou",
    --         scale = 0.12,   parent = "clip_2",
    --         loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,0,0),
    --     },},


    --  {
    --      load = {tmpl = "jttb",
    --          params = {"clip_2","2.4","6","-1200","0"},},
    --  },

    --  {action = {
    --          tag  = "xlnv",sync = false,what = {
    --          spawn = {{move = {time = 2.4,by= cc.p(200, 0), },},},
    --         },},},









    {remove = { model = {"xlnv", }, },},
    {
        load = {tmpl = "mod21",
            params = {"xlnv","hero_xiaolongnv","-100","0","0.12","clip_2"},},
    },

    {delay = {time = 1.2,},},


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


     -- {
     --     load = {tmpl = "jttb",
     --         params = {"clip_2","1.5","1","0","0"},},
     -- },

     {action = {
             tag  = "xlnv",sync = true,what = {
             spawn = {{move = {time = 2,by= cc.p(-160, -60), },},},
            },},},


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-260,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


    {
        music = {file = "backgroundmusic5.mp3",},
    },


     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("孙婆婆，你怎么样了？"),167},},
     },

     {
         load = {tmpl = "move2",
             params = {"zd","spp.png",TR("孙婆婆")},},
     },
     {
         load = {tmpl = "talk1",
             params = {"zd",TR("小姐——"),168},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zd",TR("我从来都没开口求过你——，现在我有一件事想求你答应我……"),169},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你想求我照顾他！"),170},},
     },

     {
         load = {tmpl = "talk",
             params = {"zd",TR("是！我想请小姐你照顾过儿一生一世，以后都别让人欺负他！小……小姐……你……能不能……答应我！"),171},},
     },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("照顾他一生一世？！"),172},},
     },

     {
         load = {tmpl = "talk",
             params = {"zd",TR("从……小……我就照顾你，我……我从没想过要……你报答……我……只有……这……这……一个请求……"),173},},
     },

        {delay = {time = 0.3,},},


     {
         load = {tmpl = "talk",
             params = {"xln",TR("……好！我答应你！照顾他一生一世！"),174},},
     },


    {
        load = {tmpl = "out3",
            params = {"xln","zd"},},
    },





     {
         load = {tmpl = "jt",
             params = {"clip_2","1","1","-400","0"},},
     },

     {
         load = {tmpl = "move2",
             params = {"zzj","zzj.png",TR("赵志敬")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zzj",TR("龙姑娘，杨过乃是我全真教的逆徒，还请姑娘深明大义，把他交给我们！"),175},},
     },

    {
        load = {tmpl = "out2",
            params = {"zzj"},},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_2","1","1","200","0"},},
     },


	{
        music = {file = "jq_jy1.mp3",},
    },




     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("哼！"),176},},
     },


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-260,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "talk",
             params = {"xln",TR("杨过，从今以后便是我们古墓派的人，要想带走杨过，先胜过我手中的剑！"),177},},
     },

     {
         load = {tmpl = "jt",
             params = {"clip_2","1","1","-100","0"},},
     },













    -- {action = {tag  = "zzjing", sync = true,what = {fadeout = {time = 0,},},},},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "zzjing",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.12,},},
    {bezier = {time = 0.4,to = cc.p(0,-60),
                                 control={cc.p(250,300),cc.p(100,-100),}
    },},},
    },},},


     {
         load = {tmpl = "move2",
             params = {"zzj","zzj.png",TR("赵志敬")},},
     },

     {
         load = {tmpl = "talk",
             params = {"zzj",TR("我来领教龙姑娘的高招！"),178},},
     },

    {
        load = {tmpl = "out3",
            params = {"xln","zzj"},},
    },

    {action = {tag  = "yzping", sync = true,what = {fadeout = {time = 0,},},},},
    {action = {tag  = "ylting1", sync = true,what = {fadeout = {time = 0,},},},},
    {action = {tag  = "ylting2", sync = true,what = {fadeout = {time = 0,},},},},
    {action = {tag  = "qcji", sync = true,what = {fadeout = {time = 0,},},},},

    {action = {tag  = "zzjing", sync = true,what = {fadeout = {time = 0,},},},},

    {   model = {
            tag  = "zzjing2",     type  = DEF.FIGURE,
            pos= cc.p(0,-60),    order     = 50,
            file = "hero_zhaozhijing",    animation = "nuji",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = true,  speed=1.5, rotation3D=cc.vec3(0,180,0),
        },},

        -- {delay = {time = 0.3,},},








    -- {action = {tag  = "zzjing",sync = false,what ={ spawn={{scale= {time = 0.4,to = 0.12,},},
    --           {move = {time = 0.2,by= cc.p(-20, 200), },},},},
    -- },},


    -- {action = {tag  = "zzjing2",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.12,},},
    --           {move = {time = 0.2,by= cc.p(-20, 200), },},},
    -- },},},






    -- {action = {tag  = "zzjing",sync = false,what ={ spawn={{scale= {time = 0.4,to = 0.12,},},
    --           {move = {time = 0.4,by= cc.p(-300, -160), },},},},
    -- },},


    -- {action = {tag  = "zzjing2",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.12,},},
    --           {move = {time = 0.4,by= cc.p(-300, -160), },},},
    -- },},},



    -- {action = {tag  = "zzjing", sync = true,what = {fadeout = {time = 0,},},},},
    -- {action = {tag  = "zzjing2", sync = true,what = {fadein = {time = 0,},},},},

    -- {
    --     model = {
    --         tag = "zzjing2",
    --         speed = 1.1,
    --     },
    -- },


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-260,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "nuji",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "hero_xiaolongnv_nuji.mp3",sync=false,},
    },

    {
        sound = {file = "hero_zhaozhijing_pugong.mp3",sync=false,},
    },



    {action = {tag  = "xlnv",sync = false,what ={ spawn={{scale= {time = 1.6,to = 0.12,},},
              {move = {time = 2.4,by= cc.p(550, 0), },},},},
    },},

    {action = {tag  = "zzjing2",sync = false,what ={ spawn={{scale= {time = 1.6,to = 0.12,},},
              {move = {time = 2.4,by= cc.p(700, 0), },},},
    },},},


    {delay = {time = 0.6,},},

     {
         load = {tmpl = "jttb",
             params = {"clip_2","1.5","1","-500","0"},},
     },

    {delay = {time = 1.8,},},


        {remove = { model = {"zzjing2", }, },},

    {   model = {
            tag  = "qinggong2",     type  = DEF.FIGURE,
            pos= cc.p(700,-60),    order     = 50,
            file = "hero_zhaozhijing",    animation = "aida",
            scale = 0.12,   parent = "clip_2",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},
    {delay = {time = 0.1,},},

    {action = {tag  = "qinggong2",sync = false,what ={ spawn={{bezier = {time = 0.8,to = cc.p(1100,0),
                                 control={cc.p(800,300),cc.p(1000,-100),}
    },},
    {rotate = {to = cc.vec3(0, 180, 90),time = 0.8,},},},
    },},},

        {remove = { model = {"zzjing2", }, },},

    {delay = {time = 0.6,},},


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(290,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},



    {   model = {
            tag  = "wcyi",     type  = DEF.FIGURE,
            pos= cc.p(800,-60),    order     = 50,
            file = "hero_wangchuyi",    animation = "nuji",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},


    {
        sound = {file = "hero_wangchuyi_nuji.mp3",sync=false,},
    },


    {   model = {
            tag  = "xlnv1",     type  = DEF.FIGURE,
            pos= cc.p(290,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "nuji",
            scale = 0.12,   parent = "clip_2",opacity=0,
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,0,-5),
        },},

    {delay = {time = 0.5,},},

    {action = {tag  = "xlnv1", sync = true,what = {fadein = {time = 0,},},},},

    {remove = { model = {"xlnv", }, },},
    {
        model = {
            tag = "wcyi",
            speed = 1.25,
        },
    },

    {
        model = {
            tag = "xlnv1",
            speed = -0.6,
        },
    },


    {action = {tag  = "xlnv1",sync = false,what ={ spawn={{scale= {time = 1.6,to = 0.12,},},
              {move = {time = 1.8,by= cc.p(-450, 0), },},},},
    },},

    {action = {tag  = "wcyi",sync = false,what ={ spawn={{scale= {time = 1.6,to = 0.12,},},
              {move = {time = 1.8,by= cc.p(-600, 0), },},},
    },},},

    {delay = {time = 0.2,},},

     {
         load = {tmpl = "jttb",
             params = {"clip_2","1.2","1","450","0"},},
     },

    {delay = {time = 2,},},

    {remove = { model = {"wcyi", }, },},

    {
        load = {tmpl = "mod21",
            params = {"wcyi","hero_wangchuyi","200","-60","0.12","clip_2"},},
    },

    {remove = { model = {"xlnv1", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-190,-50),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zhongshang",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {delay = {time = 0.2,},},

     {
         load = {tmpl = "move2",
             params = {"wcy","wcy.png",TR("丘处机")},},
     },
     {
         load = {tmpl = "talk",
             params = {"wcy",TR("龙姑娘，还请住手！"),179},},
     },

    -- {
    --     load = {tmpl = "out2",
    --         params = {"wcy"},},
    -- },





     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("我答应过——要照顾杨过一生一世，想要带走杨过，我唯有拼死一战了！"),180},},
     },

    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-180,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},




     -- {
     --     load = {tmpl = "jt",
     --         params = {"clip_2","0.5","2","350","0"},},
     -- },

    -- {remove = { model = {"xlnv", }, },},

    -- {   model = {
    --         tag  = "xlnv",     type  = DEF.FIGURE,
    --         pos= cc.p(-180,-40),    order     = 50,
    --         file = "hero_xiaolongnv",    animation = "nuji",
    --         scale = 0.12,   parent = "clip_2",
    --         loop = true,   endRlease = false,  speed=0.2, rotation3D=cc.vec3(0,0,0),
    --     },},


    -- {delay = {time = 1.5,},},

    -- {
    --     model = {
    --         tag = "xlnv",
    --         speed = 0.1,
    --     },
    -- },

     -- {
     --     load = {tmpl = "jttb",
     --         params = {"clip_2","1","1","-350","0"},},
     -- },

     {
         load = {tmpl = "talk",
             params = {"wcy",TR("龙姑娘！你带他走吧！从此杨过与我重阳宫再无半点瓜葛！"),181},},
     },



    {
        load = {tmpl = "out3",
            params = {"zj","wcy"},},
    },


     {
         load = {tmpl = "jttb",
             params = {"clip_2","0.5","1","350","0"},},
     },
    -- {
    --     model = {
    --         tag = "xlnv",
    --         speed = -0.6,
    --     },
    -- },

    {delay = {time = 1,},},

    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-180,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},
    {delay = {time = 0.3,},},

    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-180,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {delay = {time = 0.3,},},
    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-180,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


     -- {
     --     load = {tmpl = "jttb",
     --         params = {"clip_2","1.5","1","400","0"},},
     -- },

     {action = {
             tag  = "xlnv",sync = true,what = {
             spawn = {{move = {time = 1.2,by= cc.p(-80, 0), },},},
            },},},


    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(-260,-60),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_2",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿，我们走！"),182},},
     },


    {
        load = {tmpl = "out1",
            params = {"xln"},},
    },




        {delay = {time = 0.3,},},



    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },






    {delay={time=0.3},},

    {remove = { model = {"map0", }, },},

        {action = {tag  = "clip_2",what = {spawn = {{move = {time = "0",by = cc.p(0, 0),},},
             {scale= {time = "0",to = 0,},},},},},},




    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.9,
            size = cc.size(DEF.WIDTH, 860),},
    },



	{
        music = {file = "jq_gql.mp3",},
    },




     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑……是这个世上唯一关心过儿的人，姑姑她怎么了！？"),183},},
     },


-- --杨过扑向主角，被主角让开，委顿在地



     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("杨过！你既然在意龙姑娘？那为何要丢下她！害她差点被贼人玷污！"),30},},
     },



     {
         load = {tmpl = "talk",
             params = {"yg",TR("什……什么！？"),184},},
     },


    -- {remove = { model = {"yguo", }, },},


    -- {   model = {
    --         tag  = "yguo",     type  = DEF.FIGURE,
    --         pos= cc.p(-300,-100),    order     = 49,
    --         file = "hero_yangguo_hei",    animation = "shoushang",
    --         scale = 0.16,   parent = "clip_1", speed = 0.7,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},


    -- {delay={time=0.5},},

     {
         load = {tmpl = "talk",
             params = {"zj",TR("杨过！龙姑娘，救你，照顾你，教你武功……你便是这样报答她的吗，对她置之不顾……"),31},},
     },




-- --画面切换小龙女伤心的样子……




     {
         load = {tmpl = "talk",
             params = {"yg",TR("……姑姑！是过儿对不起你！求求你，原谅过儿，不要丢下过儿一个人！"),185},},
     },



     {
         load = {tmpl = "talk",
             params = {"zj",TR("杨过，你要是真的在意龙姑娘，就去找她，永远保护她。"),32},},
     },

    -- {remove = { model = {"yguo", }, },},


    -- {
    --     load = {tmpl = "mod22",
    --         params = {"yguo","hero_yangguo_hei","-300","-100","0.16","clip_1"},},
    -- },


     {
         load = {tmpl = "talk",
             params = {"yg",TR("对！我要找到姑姑，永远保护她，再也不让她伤心了！"),186},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("龙姑娘往山下去了，你现在去找她，也许还来得及……"),33},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("多谢两位！"),187},},
     },

    {
        load = {tmpl = "out3",
            params = {"yg","zj"},},
    },


    {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(-300,-100),    order     = 49,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.16,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "yguo",sync = true,what = {move = {
                   time = 1,by = cc.p(-500,0),},},},},

    {delay={time=0.5},},








	-- {
 --        music = {file = "jq_bgm4.mp3",},
 --    },



-- --杨过离开



     {
         load = {tmpl = "jt",
             params = {"clip_1","0.5","1","-100","0"},},
     },


    {remove = { model = {"zjue", }, },},

    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-150","-100","0.16","clip_1"},},
    },


     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("你这个笨蛋！"),188},},
     },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父，我又怎么惹你生气了？"),34},},
     },


     {
         load = {tmpl = "talk1",
             params = {"lby",TR("谁让你放跑了小龙女，别忘了我们的目的是得到玉女心经！"),189},},
     },

     {
         load = {tmpl = "talk2",
             params = {"lby",TR("赶紧下山！一定要找到小龙女！"),190},},
     },



--洛白衣剑指主角


    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
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
