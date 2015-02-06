
% these are set in sgp4init
global tumin mu radiusearthkm xke j2 j3 j4 j3oj2

global opsmode

% // ------------------------  implementation   --------------------------

% add operation smode for afspc (a) or improved (i)
opsmode='a';

% //typerun = 'c' compare 1 year of full satcat data
% //typerun = 'v' verification run, requires modified elm file with
% //typerun = 'm' maunual operation- either mfe, epoch, or dayof yr
% //              start stop and delta times
typerun = 'm';
typeinput = '20140101120000'
whichconst = 72;
rad = 180.0 / pi;

% // input 2-line element set file
infilename = 'test.tle'
longstr=loadtle(infilename);

startdate=struct('year',2014,'mon',12,'day',31,'hr',12,'min',00,'sec',00);
stopdate =struct('year',2014,'mon',12,'day',31,'hr',13,'min',00,'sec',00);
deltamin=0.1;

global idebug dbgfile

if idebug
  catno = strtrim(longstr{1}(3:7));
  dbgfile = fopen(strcat('sgp4test.dbg.',catno), 'wt');
  fprintf(dbgfile,'this is the debug output\n\n' );
end
% // convert the char string to sgp4 elements
% // includes initialization of sgp4
satrec = twoline2rv( whichconst,longstr);

%get start/stop mfe
startmfe=struct3mfe(startdate,satrec.jdsatepoch)
stopmfe =struct3mfe(stopdate, satrec.jdsatepoch)

fprintf(1,' %d\n', satrec.satnum);

% // call the propagator to get the initial state vector value
[satrec, ro ,vo] = sgp4 (satrec,  0.0);

fprintf(1, ' %16.8f %16.8f %16.8f %16.8f %12.9f %12.9f %12.9f\n',...
  satrec.t,ro(1),ro(2),ro(3),vo(1),vo(2),vo(3));

tsince = startmfe;

% // check so the first value isn't written twice
if ( abs(tsince) > 1.0e-8 )
  tsince = tsince - deltamin;
end

% // loop to perform the propagation
while ((tsince < stopmfe) && (satrec.error == 0))

  tsince = tsince + deltamin;

  if(tsince > stopmfe)
    tsince = stopmfe;
  end

  [satrec, ro, vo] = sgp4 (satrec,  tsince);

  if (satrec.error ~= 0)
    fprintf(1,'# *** error: t:= %f *** code = %3i\n', tsince, satrec.error);
  else
    jd = satrec.jdsatepoch + tsince/1440.0;
    [year,mon,day,hr,minute,sec] = invjday ( jd );

    fprintf(1, ' %16.8f %16.8f %16.8f %16.8f %12.9f %12.9f %12.9f \n',...
      tsince,ro(1),ro(2),ro(3),vo(1),vo(2),vo(3));
  end

end

if (idebug && (dbgfile ~= -1))
  fclose(dbgfile);
end

