function ports = findserial()
 % returns cell array of found serial ports under Win
 % uses CLI MODE command internally
  [~,res]=system('mode');
  ports=regexp(res,'COM\d+:','match')';
  ports = char(ports);
  % disp(ports)