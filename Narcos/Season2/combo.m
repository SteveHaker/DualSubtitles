clear all

N=10; % number of files
SwapLeftRight=1; % swap left and right subtitles?
for n=1:N
  foutname=sprintf('Combo/NarcosS02E%02d.dfxp',n);
  disp(foutname)
  copyfile('NetflixHeader.xml',foutname);
  offset=0;
  idx=[];
  for w=1:2
    name=sprintf('Original/download (%d)',2*(n-1)+w);
    in=fopen(name,'rb');
    data=fread(in,inf,"uchar=>uchar").';
    fclose(in);
    if w==1 data1=data;
    else data2=data; end
    fnd=strfind(data,'<p begin=');
    tmp=strfind(data(fnd(end):end),'</p>')+fnd(end)+3;
    fnd=[fnd tmp(1)];
    K=length(fnd)-1;
    idx=[idx; zeros(K,5)];
    for k=1:K
      txt=data(fnd(k):fnd(k+1)-1);
      tx1=txt(11:30);
      e=find(tx1=='t',1)-1;
      idx(offset+k,1)=eval(tx1(1:e));
      fn2=strfind(txt,'end=');
      tx1=txt(fn2(1)+5:end);
      e=find(tx1=='t',1)-1;
      idx(offset+k,2)=eval(tx1(1:e));
      idx(offset+k,3:5)=[w fnd(k) fnd(k+1)-1];
    end
    offset=K;
  end
  fout=fopen(foutname,'ab');
  idx=sortrows(idx,[1 3]);
  K=size(idx,1);
  fmt='<p begin="%dt" end="%dt" region="region_%d%d" xml:id="subtitle%d">';
  for k=1:K
    if k==1 last_start=idx(1,1)-1; last_region=0; end
    if all([ idx(k,1)==last_start; idx(k,3)==last_region]) sub_region=sub_region+1;
    else sub_region=0; end
    last_start=idx(k,1);
    last_region=idx(k,3);
    if idx(k,3)==1 txt=data1(idx(k,4):idx(k,5));
    else
      txt=data2(idx(k,4):idx(k,5));
      % handle any id clashes
      % txt=strrep(txt,'style_0','es_style_0');
    end
    fnd=find(txt=='>',1);
    region=idx(k,3)-1; if SwapLeftRight==1 region=1-region; end 
    tx2=[sprintf(fmt,idx(k,1),idx(k,2),region,sub_region,k) txt(fnd+1:end)];
    fwrite(fout,tx2);
  end
  fprintf(fout,'\n</div>\n</body>\n</tt>\n');
  fclose(fout);
end
