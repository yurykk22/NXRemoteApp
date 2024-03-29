# NXRemoteApp
Удаленный запуск Linux-приложений на Рабочем столе Windows
* протестировано на Ubuntu 20.04.3

Установка на Linux:  
1. Сохранить скрипт `linux/usr_local_bin/nxstart` в `/usr/local/bin/nxstart`  
2. Добавить права запуска на данный скрипт  
`# chmod +x /usr/local/bin/nxstart`  
3. Установить nxagent  
`# apt install nxagent`  
  
Установка на Windows:  
1. Скачать и проинсталлировать пакет [X2GO Client](https://wiki.x2go.org/doku.php/download:start). Пакет содержит все необходимые приложения и библиотеки  
2. Сохранить папку `win/NXRemoteApp` в `Program Files`  
3. Сохранить и настроить ярлыки запуска из `win/Desktop`  
  
Команда запуска:  
`NXRemoteApp.vbs [options] <login> <host> <linuxapp>`  
  
Параметры запуска:  
|||
|--|--|
|`-pw <password>`	| Пароль входа<br />При указании пароля применяется параметр `-plink`|
|`-i  <privatekey>`	| Файл закрытого ключа				|
|`-kb <kbmode>`		| Переключение раскладки<br />`0` - `Alt+Shift`, `1` - `Ctrl+Shift`|
|`-disp <display>`	| Номер X дисплея<br />`-1` - Определяет дисплей по SID<br />`-2` - Новый дисплей под каждый процесс|
|`-xsrvpath <path>`	| Путь к приложению VcXsrv			|
|`-nxpath <path>`	| Путь к приложению nxproxy			|
|`-plinkpath <path>`	| Путь к приложению plink			|
|`-pulsepath <path>`	| Путь к приложению PulseAudio			|
|`-plink`		| Не использовать OpenSSH			|
|`-audio`		| Включить канал передачи аудио			|
|`-d`			| Режим отладки					|
