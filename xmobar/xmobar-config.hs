Config { font    = "xft:Source Code Pro:weight=bold:pixelsize=10:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Mononoki Nerd Font:pixelsize=10:antialias=true:hinting=true"
                           , "xft:Font Awesome 5 Free Solid:pixelsize=10"
                           , "xft:Font Awesome 5 Brands:pixelsize=10"
                           ]
       , bgColor = "#282C34"
       , fgColor = "#FF6C6B"
       , position = Static { xpos = 0, ypos = 0, width = 1920, height = 18 }
       , lowerOnStart = True
       , hideOnStart = False
       , persistent = True
       , overrideRedirect = False
       , commands = [
                      Run Date "<fn=2>\xf017</fn> %b %d %Y - %H:%M" "date" 50
                    , Run Battery [ "--template" , "<acstatus>"
                                , "--L" , "20"
                                , "--H" , "50"
                                , "--low"      , "darkred"
                                , "--normal"   , "darkorange"
                                , "--high"     , "#1ABC9C"
                                , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"   , "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"   , "<fc=#98be65>Charging</fc>"
                                       -- charged status
                                       , "-i"   , "<fc=#98be65>Charged</fc>"
                                ] 20
                    , Run Network "wlan0" ["-t","<fn=2>\xf0ab</fn> <rx>kb  <fn=2>\xf0aa</fn> <tx>kb"] 20
                    , Run Cpu ["-t", "<fn=2>\xf108</fn> cpu: (<total>%)","-H","50","--high","red"] 20
                    , Run Memory ["-t", "<fn=2>\xf233</fn> mem: <used>M (<usedratio>%)"] 20
                    , Run DiskU [("/", "<fn=2>\xf0c7</fn> hdd: <free> free")] [] 60
                    , Run Com "/home/natew/.config/xmobar/trayer-padding-icon.sh" [] "trayerpad" 10
                    , Run UnsafeStdinReader
                    ]
    , sepChar = "%"
    , alignSep = "}{"
    , template = " %UnsafeStdinReader% }{ <fc=#98be65> %battery% </fc><fc=#666666>|</fc><fc=#A9A1E1> <action=`alacritty -e sudo iftop`>%wlan0%</action> </fc><fc=#666666>|</fc><fc=#ecbe7b> <action=`alacritty -e htop`>%cpu%</action> </fc><fc=#666666>|</fc><fc=#ff6c6b> <action=`alacritty -e htop`>%memory%</action></fc><fc=#51afef> <fc=#666666>|</fc> <action=`alacritty -e htop`>%disku%</action> </fc><fc=#666666>|</fc><fc=#46d9ff> <action=`emacsclient -c -a 'emacs' --eval '(doom/window-maximize-buffer(org-agenda))'`>%date%</action> </fc><fc=#666666><fn=1>|</fn></fc>%trayerpad%"
}
