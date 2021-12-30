import Data.Char (isSpace, toUpper)
import qualified Data.Map as M
import Data.Maybe (fromJust, isJust)
import Data.Monoid
import Data.Tree
import System.Directory
import System.Exit (exitSuccess)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D (..), WSType (..), moveTo, nextScreen, prevScreen, shiftTo, toggleWS)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotAllDown, rotSlavesDown)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.ManageHelpers (doCenterFloat, doFullFloat, isFullscreen)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (decreaseLimit, increaseLimit, limitWindows)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (EOT (EOT), mkToggle, single, (??))
import qualified XMonad.Layout.MultiToggle as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet as W
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:Source Code Pro:regular:size=10:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty" -- Sets default terminal

myBrowser :: String
myBrowser = "brave" -- Sets qutebrowser as browser

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' " -- Makes emacs keybindings easier to type

myEditor :: String
-- myEditor = "emacsclient -c -a 'emacs' "  -- Sets emacs as editor
myEditor = myTerminal ++ " -e nvim " -- Sets vim as editor

myBorderWidth :: Dimension
myBorderWidth = 2 -- Sets border width for windows

myNormColor :: String
myNormColor = "#bd93f9" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#ff79c6" -- Border color of focused windows

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "asus-kbd-backlight max"
  spawnOnce "nm-applet &"
  spawnOnce "flameshot &"
  spawnOnce "udiskie -s &"
  spawnOnce "dropbox &"
  spawnOnce "fcitx -d &"
  spawnOnce "volumeicon &"
  spawnOnce "/usr/bin/emacs --daemon &"
  spawnOnce "nitrogen --restore &"

  -- using just 'spawn' makes sure that trayer doesn't get drawn over by xmobar on restart
  spawn "sleep 2 && trayer --edge top --align right --widthtype request --padding 6 --iconspacing 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x282c34 --height 18 &"
  setWMName "XMonad"

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" spawnTerm findTerm manageTerm,
    NS "mocp" spawnMocp findMocp manageMocp,
    NS "calculator" spawnCalc findCalc manageCalc,
    NS "spotify" spawnSpotify findSpotify manageSpotify,
    NS "htop" spawnHtop findHtop manageHtop,
    NS "ranger" spawnRanger findRanger manageRanger
  ]
  where
    spawnTerm = myTerminal ++ " -t scratchpad"
    findTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnMocp = myTerminal ++ " -t mocp -e mocp"
    findMocp = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnCalc = "qalculate-gtk"
    findCalc = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
      where
        h = 0.5
        w = 0.4
        t = 0.75 - h
        l = 0.70 - w
    spawnSpotify = myTerminal ++ " -t spotify -e spt"
    findSpotify = title =? "spotify"
    manageSpotify = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnHtop = myTerminal ++ " -t htop -e htop"
    findHtop = title =? "htop"
    manageHtop = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnRanger = myTerminal ++ " -t ranger-float -e ranger"
    findRanger = title =? "ranger-float"
    manageRanger = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                ResizableTall 1 (3 / 100) (1 / 2) []

magnify =
  renamed [Replace "magnify"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            magnifier $
              limitWindows 12 $
                mySpacing 8 $
                  ResizableTall 1 (3 / 100) (1 / 2) []

floats =
  renamed [Replace "floats"] $
    smartBorders $
      limitWindows 20 simplestFloat

grid =
  renamed [Replace "grid"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                mkToggle (single MIRROR) $
                  Grid (16 / 10)

tabs =
  renamed [Replace "tabs"] $
    noBorders $
      tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme =
  def
    { fontName = "xft:Source Code Pro:regular:size=8:antialias=true:hinting=true",
      activeColor = "#ff79c6",
      inactiveColor = "#313846",
      activeBorderColor = "#ff79c6",
      inactiveBorderColor = "#282c34",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts tabs $ -- this was floats before
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder myBorderWidth tall
        ||| magnify
        ||| floats
        ||| tabs
        ||| grid

-- myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
myWorkspaces = [" main ", " dev ", " chem ", " swe ", " kanji ", " distr ", " chat ", " cli ", " temp "]

myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    -- I'm doing it this way because otherwise I would have to write out the full
    -- name of my workspaces and the names would be very long if using clickable workspaces.
    [ className =? "confirm" --> doCenterFloat,
      className =? "file_progress" --> doCenterFloat,
      className =? "dialog" --> doCenterFloat,
      className =? "download" --> doCenterFloat,
      className =? "error" --> doCenterFloat,
      className =? "notification" --> doCenterFloat,
      className =? "pinentry-gtk-2" --> doFloat,
      className =? "splash" --> doFloat,
      className =? "toolbar" --> doFloat,
      className =? "Gimp" --> doFloat,
      className =? "Yad" --> doCenterFloat,
      -- float Thunar pop-ups
      title =? "File Operation Progress" --> doCenterFloat,
      title =? "Confirm to replace files" --> doCenterFloat,
      title =? "Save File" --> doCenterFloat,
      (className =? "thunar" <&&> title =? "Open") --> doCenterFloat,
      -- send some programs to a specific workspace
      className =? "discord" --> doShift (myWorkspaces !! 6),
      -- send browser tabs for different classes to different workspaces
      title =? "Chemistry - Brave" --> doShift (myWorkspaces !! 2),
      title =? "Japanese IV - Brave" --> doShift (myWorkspaces !! 3),
      title =? "Geology - Brave" --> doShift (myWorkspaces !! 4),
      title =? "Compilers - Brave" --> doShift (myWorkspaces !! 5),
      -- fullscreen float any fullscreen apps
      isFullscreen --> doFullFloat,
      title =? "Oracle VM VirtualBox Manager" --> doFloat
    ]
    <+> namedScratchpadManageHook myScratchPads

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
  -- KB_GROUP Xmonad
  [ ("M-S-r", spawn "killall trayer; xmonad --restart"), -- Restarts xmonad
    ("M-C-r", spawn "xmonad --recompile"), -- Recompiles xmonad
    ("M-S-q", io exitSuccess), -- Quits xmonad

    -- KB_GROUP Run Prompt
    ("M-<Return>", spawn "dmenu_run -i -p \"Run: \""), -- Dmenu

    -- KB_GROUP Useful programs to have a keybinding for launch
    ("M-S-<Return>", spawn myTerminal),
    ("M-S-b", spawn myBrowser),
    ("M-e", spawn "thunar"),
    ("M-r", spawn "alacritty -t ranger -e ranger"),
    ("M-S-e", spawn "emacs"),
    ("M-M1-h", spawn (myTerminal ++ " -e htop")),
    -- KB_GROUP Kill windows
    ("M-S-c", kill1), -- Kill the currently focused client
    ("M-S-a", killAll), -- Kill all windows on current workspace

    -- KB_GROUP Workspaces
    ("M-`", nextScreen),  -- Switch focus to next monitor
    ("M-S-`", prevScreen),  -- Switch focus to prev monitor
    ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP), -- Shifts focused window to next ws
    ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP), -- Shifts focused window to prev ws

    -- KB_GROUP Floating windows
    ("M-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-t-p", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-p-a", sinkAll), -- Push ALL floating windows to tile

    -- KB_GROUP Increase/decrease spacing (gaps)
    ("C-M1-j", decWindowSpacing 4), -- Decrease window spacing
    ("C-M1-k", incWindowSpacing 4), -- Increase window spacing
    ("C-M1-h", decScreenSpacing 4), -- Decrease screen spacing
    ("C-M1-l", incScreenSpacing 4), -- Increase screen spacing

    -- KB_GROUP Windows navigation
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-w", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-S-j", windows W.swapDown), -- Swap focused window with next window
    ("M-S-k", windows W.swapUp), -- Swap focused window with prev window
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack
    ("M-<Tab>", toggleWS), -- Switch to last workspace

    -- KB_GROUP Layouts
    ("M-S-l", sendMessage NextLayout), -- Switch to next layout
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full
    ("M-S-t", sendMessage (T.Toggle "tabs")), -- Toggles my 'tabs' layout

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
    ("M-S-<Up>", sendMessage (IncMasterN 1)), -- Increase # of clients master pane
    ("M-S-<Down>", sendMessage (IncMasterN (-1))), -- Decrease # of clients master pane
    ("M-C-<Up>", increaseLimit), -- Increase # of windows
    ("M-C-<Down>", decreaseLimit), -- Decrease # of windows

    -- KB_GROUP Window resizing
    ("M-h", sendMessage Shrink), -- Shrink horiz window width
    ("M-l", sendMessage Expand), -- Expand horiz window width
    ("M-M1-j", sendMessage MirrorShrink), -- Shrink vert window width
    ("M-M1-k", sendMessage MirrorExpand), -- Expand vert window width

    -- KB_GROUP Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
    ("M-C-h", sendMessage $ pullGroup L),
    ("M-C-l", sendMessage $ pullGroup R),
    ("M-C-k", sendMessage $ pullGroup U),
    ("M-C-j", sendMessage $ pullGroup D),
    ("M-C-m", withFocused (sendMessage . MergeAll)),
    ("M-C-u", withFocused (sendMessage . UnMerge)),
    ("M-C-/", withFocused (sendMessage . UnMergeAll)),
    ("M-C-.", onGroup W.focusUp'), -- Switch focus to next tab
    ("M-C-,", onGroup W.focusDown'), -- Switch focus to prev tab

    -- KB_GROUP Scratchpads
    -- Toggle show/hide these programs.  They run on a hidden workspace.
    -- When you toggle them to show, it brings them to your current workspace.
    -- Toggle them to hide and it sends them back to hidden workspace (NSP).
    ("M-s t", namedScratchpadAction myScratchPads "terminal"),
    ("M-s c", namedScratchpadAction myScratchPads "calculator"),
    ("M-s m", namedScratchpadAction myScratchPads "spotify"),
    ("M-s h", namedScratchpadAction myScratchPads "htop"),
    ("M-s r", namedScratchpadAction myScratchPads "ranger"),

    -- screenshots
    ("M-s s", spawn "flameshot gui"),
    ("M-s f", spawn "flameshot full -p ~/Documents/Screenshots"),

    -- power management
    ("M-p s", spawn "shutdown now"),
    ("M-p r", spawn "reboot"),
    ("M-p l", spawn "systemctl suspend"),

    -- jump to specific workspaces
    ("M-z c", windows $ W.greedyView (myWorkspaces !! 2)),
    ("M-z s", windows $ W.greedyView (myWorkspaces !! 3)),
    ("M-z k", windows $ W.greedyView (myWorkspaces !! 4)),
    ("M-z t", windows $ W.greedyView (myWorkspaces !! 5)),
    ("M-z d", windows $ W.greedyView (myWorkspaces !! 6)),

    -- KB_GROUP Emacs (CTRL-e followed by a key)
    ("C-e r", spawn (myEmacs ++ "--eval '(dashboard-refresh-buffer)'")), -- emacs dashboard
    ("C-e b", spawn (myEmacs ++ "--eval '(ibuffer)'")), -- list buffers
    ("C-e d", spawn (myEmacs ++ "--eval '(dired nil)'")), -- dired
    ("C-e i", spawn (myEmacs ++ "--eval '(erc)'")), -- erc irc client
    ("C-e v", spawn (myEmacs ++ "--eval '(+vterm/here nil)'")), -- vterm if on Doom Emacs
    ("C-e e", spawn "emacsclient --eval '(emacs-everywhere)'"), -- launch emacs-everywhere
    ("C-e x", spawn "emacs ~/.config/xmonad/xmonad.hs"), -- open xmonad config file in emacs

    -- KB_GROUP Multimedia Keys
    ("<XF86AudioPlay>", spawn "mocp --play"),
    ("<XF86AudioPrev>", spawn "mocp --previous"),
    ("<XF86AudioNext>", spawn "mocp --next"),
    ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 10%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 10%+ unmute"),
    ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
  ]
  where
    -- The following lines are needed for named scratchpads.
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

-- END_KEYS

main :: IO ()
main = do
  xmproc0 <- spawnPipe "xmobar $HOME/.config/xmobar/xmobar-config.hs"
  xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobar-config.hs"
  xmonad $
    ewmh
      def
        { manageHook = myManageHook <+> manageDocks,
          handleEventHook = docksEventHook,
          -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
          -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
          -- it adds a border around the window if screen does not have focus. So, my solution
          -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
          -- <+> fullscreenEventHook
          modMask = myModMask,
          terminal = myTerminal,
          layoutHook = myLayoutHook,
          startupHook = myStartupHook,
          workspaces = myWorkspaces,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          logHook =
            dynamicLogWithPP $
              namedScratchpadFilterOutWorkspacePP $
                xmobarPP
                  { -- the following variables beginning with 'pp' are settings for xmobar.
                    -- ppOutput = hPutStrLn xmproc0, -- xmobar
                    ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                                  >> hPutStrLn xmproc1 x,
                    ppCurrent = xmobarColor "#C792EA" "" . wrap "<box type=Bottom width=1 mb=2 color=#C792EA>" "</box>", -- Current workspace
                    ppVisible = xmobarColor "#C792EA" "" . clickable, -- Visible but not current workspace
                    ppHidden = xmobarColor "#82AAFF" "" . wrap "<box type=Top width=1 mb=2 color=#82AAFF>" "</box>" . clickable, -- Hidden workspaces
                    ppHiddenNoWindows = xmobarColor "#98A0B0" "" . clickable, -- Hidden workspaces (no windows)
                    ppTitle = xmobarColor "#B3AFC2" "" . shorten 60, -- Title of active window
                    ppSep = "<fc=#666666> <fn=1>|</fn> </fc>", -- Separator character
                    ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!", -- Urgent workspace
                    -- , ppExtras  = [windowCount]                                     -- # of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t] -- order of things in xmobar
                  }
        }
      `additionalKeysP` myKeys
