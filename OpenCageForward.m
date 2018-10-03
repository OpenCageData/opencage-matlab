function [results]=OpenCageForward(key,q,varargin)
%%  OpenCageForward
%   This package is an interface to the OpenCage API that allows forward 
%   and reverse geocoding. To use the package, you will need an API key. 
%   To get an API key for OpenCage geocoding, register at 
%   https://geocoder.opencagedata.com/pricing. The free API key provides 
%   up to 2,500 calls a day.
%
%   Required input variables:
%
%   key             API key variable
%   q               one-line character variable containing the address you 
%                   are searching geo-data for
%
%   Additional optional parameters are
%
%   abbrv           When set to 1 we attempt to abbreviate and shorten the 
%                   formatted string we return. 
%   add_request     When set to 1 the various request parameters are added 
%                   to the response for ease of debugging.
%   bounds          Provides the geocoder with a hint to the region that 
%                   the query resides in. This value will restrict the 
%                   possible results to the supplied region. The value of 
%                   the bounds parameter should be specified as two 
%                   coordinate points forming the south-west and north-east 
%                   corners of a bounding box. For example: 
%                   bounds='-0.563160,51.280430,0.278970,51.683979'
%                   (min lon, min lat, max lon, max lat).
%   countrycode     Restricts the results to the specified country or 
%                   countries.
%                   The country code is a two letter code as defined by the 
%                   ISO 3166-1 Alpha 2 standard. E.g. gb for the United 
%                   Kingdom, fr for France, us for United States. Please 
%                   note, many non-country territories have their own code, 
%                   for example pr for Puerto Rico.
%                   You can specify multiple codes by supplying a comma 
%                   separated list. For example 
%                   countrycode='fr,bl,gf,gp,mf,mq,nc,pf,pm,re,tf,wf,yt' 
%                   would be all French territories.
%                   Non-two letter countrycodes are ignored.
%   language        An IETF format language code (such as es for Spanish 
%                   or pt-BR for Brazilian Portuguese).
%                   If no language is explicitly specified, we will then 
%                   look for an HTTP Accept-Language header like those sent 
%                   by a browser and use highest quality language specified 
%                   (please see RFC 4647 for details). If the request did 
%                   not specify a valid header, then en (English) will be 
%                   assumed.
%                   Please note, setting the language parameter does NOT 
%                   mean results will only be returned in the specified 
%                   language. Instead it means we will attempt to favour 
%                   results in that language.
%   limit           The maximum number of results we should return. Default 
%                   is 10. Maximum allowable value is 100.
%   min_confidence  An integer from 1-10. Only results with at least this 
%                   confidence will be returned. 
%   no_annotations  When set to 1 results will not contain annotations.
%   no_dedupe       When set to 1 results will not be deduplicated.
%   no_record       When set to 1 the query contents are not logged. Please 
%                   use if you have concerns about privacy and want us to 
%                   have no record of your query.
%   pretty          When set to 1 results are 'pretty' printed for easier 
%                   reading. Useful for debugging
%   proximity       Used only for forward geocoding. Provides the geocoder 
%                   with a hint to bias results in favour of those closer 
%                   to the specified location. Please note though, this is 
%                   just one of many factors in the internal scoring we use 
%                   for ranking results. The value is a point with latitude, 
%                   longitude coordinates in decimal format. For example: 
%                   proximity='41.40139,2.12870'
%                   Values that are not valid coordinates are ignored.
%
%   An more detailed explanation can be found at 
%   https://opencagedata.com/api#forward-opt
%
%   Sample code:    
%   


%%  Additional (optional) parameters
abbrv=0;
add_request=0;
bounds='';
countrycode='';
language='';
limit='';
min_confidence=0;
no_annotations=0;
no_dedupe=0;
no_record=0;
pretty=0;
proximity='';

%%  Dynamic read
list=who;
if nargin>2
    opt=[];arg_list=[];
    pos=1;flag_thereismore=1;
    %%  check if argument gives us a structure
    if flag_thereismore
        if isstruct(varargin{pos})
            opt=varargin{pos};
            pos=pos+1;
            flag_thereismore=nargin>pos;
        end
    end
    %%  check for name-variable pairs
    if flag_thereismore
        if ((nargin-1-pos)/2)==fix((nargin-1-pos)/2)
            arg_list=varargin(pos:end);
        else
            error('No of arguments is off.')
        end
    end
    %%  add option structure variables if they are part of the list
    if ~isempty(opt)
        for i1=1:numel(list)
            if isfield(opt, char(list{i1}))
                eval(horzcat(matlab.lang.makeValidName(char(list(i1))),'=opt.',char(list{i1}),';'));
            end
        end
    end
    %%  add name-value pair arguments if they are part of the list
    if ~isempty(arg_list)
        for i1=1:numel(arg_list)/2
            if ismember(arg_list{(i1-1)*2+1},list)
                if isnumeric(arg_list{(i1-1)*2+2})
                    eval(horzcat(arg_list{(i1-1)*2+1},'=',arg_list{(i1-1)*2+2},';'));                    
                else
                    eval(sprintf('%s=[%s];',arg_list{(i1-1)*2+1},mat2str(arg_list{(i1)*2})));
                end
            end
        end
    end
end

%%  Fix parameters
url='https://api.opencagedata.com/geocode/v1/json?q=';

%%  Baseline search modification
%   get rid of excess spaces
q = regexprep(q,' +',' ');
%   convert spaces to +
q=strrep(q,' ','+');
%   convert commata to 2%C
q=strrep(q,',','%2C');
%   baseline search with URL
req=horzcat(url,q,'&key=',key);

%%  Adding optional parameters to the request
if abbrv==1
    req=horzcat(req,'&abbrv=',num2str(1));
end
if add_request==1
    req=horzcat(req,'&add_request=',num2str(1));
end
if min_confidence>0
    req=horzcat(req,'&min_confidence=',num2str(min_confidence));
end
if no_annotations==1
    req=horzcat(req,'&no_annotations=',num2str(1));
end
if no_dedupe==1
    req=horzcat(req,'&no_dedupe=',num2str(1));
end
if no_record==1
    req=horzcat(req,'&no_record=',num2str(1));
end
if pretty==1
    req=horzcat(req,'&pretty=',num2str(1));
end
if ~isempty(bounds)
    req=horzcat(req,'&bounds=',bounds);
end
if ~isempty(countrycode)
    req=horzcat(req,'&countrycode=',countrycode);
end
if ~isempty(language)
    req=horzcat(req,'&language=',language);
end
if ~isempty(limit)
    if isnumeric(limit)
        req=horzcat(req,'&limit=',num2str(limit));
    else
        req=horzcat(req,'&limit=',limit);
    end
end
if ~isempty(proximity)
    req=horzcat(req,'&proximity=',proximity);
end

%%  Send request
results = webread(req);

end