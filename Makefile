SHELL = /bin/bash

CC=g++

OBJS =  UdpSlot.o Rebalance.o \
	Msg13.o Mime.o IndexReadInfo.o \
	PageGet.o PageHosts.o PageIndexdb.o \
	PageParser.o PageInject.o PagePerf.o PageReindex.o PageResults.o \
	PageAddUrl.o PageRoot.o PageSockets.o PageStats.o \
	PageTitledb.o \
	PageAddColl.o \
	hash.o Domains.o \
	Collectiondb.o \
	linkspam.o ip.o sort.o \
	fctypes.o XmlNode.o XmlDoc.o Xml.o \
	Words.o Url.o UdpServer.o \
	Threads.o Titledb.o HashTable.o \
	TcpServer.o Summary.o \
	Spider.o \
	Catdb.o \
	RdbTree.o RdbScan.o RdbMerge.o RdbMap.o RdbMem.o RdbBuckets.o \
	RdbList.o RdbDump.o RdbCache.o Rdb.o RdbBase.o \
	Query.o Phrases.o Multicast.o Msg9b.o\
	Msg8b.o Msg5.o \
	Msg39.o Msg37.o Msg36.o Msg3.o \
	Msg22.o \
	Msg20.o Msg2.o \
	Msg1.o Msg35.o \
	Msg0.o Mem.o Matches.o Loop.o \
	Log.o Lang.o \
	Indexdb.o Posdb.o Clusterdb.o IndexList.o Revdb.o \
	HttpServer.o HttpRequest.o \
	HttpMime.o Hostdb.o \
	Highlight.o File.o Errno.o Entities.o \
	Dns.o Dir.o Conf.o Bits.o \
	Stats.o BigFile.o Msg17.o \
	Speller.o DiskPageCache.o \
	PingServer.o StopWords.o TopTree.o \
	Parms.o Pages.o \
	Unicode.o iana_charset.o Iso8859.o \
	SearchInput.o \
	Categories.o Msg2a.o PageCatdb.o PageDirectory.o \
	SafeBuf.o Datedb.o \
	UCNormalizer.o UCPropTable.o UnicodeProperties.o \
	Pops.o Title.o Pos.o LangList.o \
	Profiler.o \
	AutoBan.o Msg3a.o HashTableT.o HashTableX.o \
	PageLogView.o Msg1f.o Blaster.o MsgC.o \
	PageSpam.o Proxy.o PageThreads.o Linkdb.o \
	matches2.o LanguageIdentifier.o \
	Language.o Repair.o Process.o \
	Abbreviations.o \
	RequestTable.o TuringTest.o Msg51.o geo_ip_table.o \
	Msg40.o Msg4.o \
	LanguagePages.o \
	Statsdb.o PageStatsdb.o \
	PostQueryRerank.o Msge0.o Msge1.o \
	CountryCode.o DailyMerge.o CatRec.o Tagdb.o \
	Users.o Images.o Wiki.o Wiktionary.o Scraper.o \
	Dates.o Sections.o SiteGetter.o Syncdb.o qa.o \
	Placedb.o Address.o Test.o GeoIP.o GeoIPCity.o Synonyms.o \
	Cachedb.o Monitordb.o dlstubs.o PageCrawlBot.o Json.o PageBasic.o


CHECKFORMATSTRING = -D_CHECK_FORMAT_STRING_

DEFS = -D_REENTRANT_ $(CHECKFORMATSTRING) -I.

HOST=$(shell hostname)

#print_vars:
#	$(HOST)

ifeq ("titan","$(HOST)")
# my machine, titan, runs the old 2.4 kernel, it does not use pthreads because
# they were very buggy in 1999. Plus they are still kind of slow even today,
# in 2013. So it just uses clone() and does its own "threading". Unfortunately,
# the way it works is not even possible on newer kernels because they no longer
# allow you to override the _errno_location() function. -- matt
# -DMATTWELLS
CPPFLAGS = -m32 -g -Wall -pipe -Wno-write-strings -Wstrict-aliasing=0 -Wno-uninitialized -static -DTITAN
LIBS = ./libz.a ./libssl.a ./libcrypto.a ./libiconv.a ./libm.a
else
# use -m32 to force 32-bit mode compilation.
# you might have to do apt-get install gcc-multilib to ensure that -m32 works.
# -m32 should use /usr/lib32/ as the library path.
# i also provide 32-bit libraries for linking that are not so easy to get.
#
# mdw. 11/17/2013. i took out the -D_PTHREADS_ flag (and -lpthread).
# trying to use good ole' clone() again because it seems the errno location
# thing is fixed by just ignoring it.
#
CPPFLAGS = -m32 -g -Wall -pipe -Wno-write-strings -Wstrict-aliasing=0 -Wno-uninitialized -static -DPTHREADS -Wno-unused-but-set-variable
LIBS= -L. ./libz.a ./libssl.a ./libcrypto.a ./libiconv.a ./libm.a ./libstdc++.a -lpthread
endif

# if you have seo.cpp link that in. This is not part of the open source
# distribution but is available for interested parties.
ifneq ($(wildcard seo.cpp),) 
OBJS:=$(OBJS) seo.o
endif



# let's keep the libraries in the repo for easier bug reporting and debugging
# in general if we can. the includes are still in /usr/include/ however...
# which is kinda strange but seems to work so far.
#LIBS= -L. ./libz.a ./libssl.a ./libcrypto.a ./libiconv.a ./libm.a ./libgcc.a ./libpthread.a ./libc.a ./libstdc++.a 



#SRCS := $(OBJS:.o=.cpp) main.cpp


all: gb

g8: gb
	scp gb g8:/p/gb.new
	ssh g8 'cd /p/ ; ./gb stop ; ./gb installgb ; sleep 4 ; ./gb start'

utils: addtest blaster2 dump hashtest makeclusterdb makespiderdb membustest monitor seektest urlinfo treetest dnstest dmozparse gbtitletest

gb: $(OBJS) main.o $(LIBFILES)
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ main.o $(OBJS) $(LIBS)


#iana_charset.cpp: parse_iana_charsets.pl character-sets supported_charsets.txt
#	./parse_iana_charsets.pl < character-sets

#iana_charset.h: parse_iana_charsets.pl character-sets supported_charsets.txt
#	./parse_iana_charsets.pl < character-sets

run_parser: test_parser
	./test_parser ~/turkish.html

test_parser: $(OBJS) test_parser.o Makefile 
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ test_parser.o $(OBJS) $(LIBS)
test_parser2: $(OBJS) test_parser2.o Makefile 
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ test_parser2.o $(OBJS) $(LIBS)

test_hash: test_hash.o $(OBJS)
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ test_hash.o $(OBJS) $(LIBS)
test_norm: $(OBJS) test_norm.o
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ test_norm.o $(OBJS) $(LIBS)
test_convert: $(OBJS) test_convert.o
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ test_convert.o $(OBJS) $(LIBS)

supported_charsets: $(OBJS) supported_charsets.o supported_charsets.txt
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ supported_charsets.o $(OBJS) $(LIBS)
gbchksum: gbchksum.o
	g++ -g -Wall -o $@ gbchksum.o
create_ucd_tables: $(OBJS) create_ucd_tables.o
	g++ $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ create_ucd_tables.o $(OBJS) $(LIBS)

ucd.o: ucd.cpp ucd.h

ucd.cpp: parse_ucd.pl
	./parse_ucd.pl UNIDATA/UnicodeData.txt ucd


ipconfig: ipconfig.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o -lc
blaster2: $(OBJS) blaster2.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
udptest: $(OBJS) udptest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
dnstest: $(OBJS) dnstest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
thunder: thunder.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -static -o $@ $@.o
threadtest: threadtest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o -lpthread
memtest: memtest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o 
hashtest: hashtest.cpp
	$(CC) -O3 -o hashtest hashtest.cpp
hashtest0: hashtest
	scp hashtest gb0:/a/
membustest: membustest.cpp
	$(CC) -O0 -o membustest membustest.cpp -static -lc
mergetest: $(OBJS) mergetest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
addtest: $(OBJS) addtest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
addtest0: $(OBJS) addtest
	bzip2 -fk addtest
	scp addtest.bz2 gb0:/a/
seektest: seektest.cpp
	$(CC) -o seektest seektest.cpp -lpthread
treetest: $(OBJ) treetest.o
	$(CC) $(DEFS) $(DEFS2) -O2 $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
treetest0: treetest
	bzip2 -fk treetest
	scp treetest.bz2 gb0:/a/
	ssh gb0 'cd /a/ ; rm treetest ; bunzip2 treetest.bz2'
nicetest: nicetest.o
	$(CC) -o nicetest nicetest.cpp


monitor: $(OBJS) monitor.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ monitor.o $(OBJS) $(LIBS)
reindex: $(OBJS) reindex.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
convert: $(OBJS) convert.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
maketestindex: $(OBJS) maketestindex.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
makespiderdb: $(OBJS) makespiderdb.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
makespiderdb0: makespiderdb
	bzip2 -fk makespiderdb
	scp makespiderdb.bz2 gb0:/a/
makeclusterdb: $(OBJS) makeclusterdb.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
makeclusterdb0: makeclusterdb
	bzip2 -fk makeclusterdb
	scp makeclusterdb.bz2 gb0:/a/
	ssh gb0 'cd /a/ ; rm makeclusterdb ; bunzip2 makeclusterdb.bz2'
makefix: $(OBJS) makefix.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
makefix0: makefix
	bzip2 -fk makefix
	scp makefix.bz2 gb0:/a/
urlinfo: $(OBJS) urlinfo.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $(OBJS) urlinfo.o $(LIBS)

dmozparse: $(OBJS) dmozparse.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
gbfilter: gbfilter.cpp
	g++ -g -o gbfilter gbfilter.cpp -static -lc
gbtitletest: gbtitletest.o
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)


# comment this out for faster deb package building
clean:
	-rm -f *.o gb *.bz2 blaster2 udptest memtest hashtest membustest mergetest seektest addtest monitor reindex convert maketestindex makespiderdb makeclusterdb urlinfo gbfilter dnstest thunder dmozparse gbtitletest gmon.* GBVersion.cpp quarantine core core.*

.PHONY: GBVersion.cpp

convert.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

StopWords.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Places.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Loop.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

hash.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

fctypes.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

IndexList.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Matches.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Highlight.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

matches2.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

linkspam.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Matchers.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

HtmlParser.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 


# Url::set() seems to take too much time
Url.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# Sitedb has that slow matching code
Sitedb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Catdb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# when making a new file, add the recs to the map fast
RdbMap.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# this was getting corruption, was it cuz we used -O2 compiler option?
# RdbTree.o:
# 	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

RdbBuckets.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

Linkdb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

XmlDoc.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

# final gigabit generation in here:
Msg40.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

seo.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

TopTree.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

UdpServer.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

RdbList.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Rdb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

RdbBase.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# RdbCache.cpp gets "corrupted" with -O2... like RdbTree.cpp
#RdbCache.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# fast dictionary generation and spelling recommendations
#Speller.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# O2 seems slightly faster than O2 on this for some reason
# O2 is almost twice as fast as no O
IndexTable.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

IndexTable2.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Posdb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# Query::setBitScores() needs this optimization
#Query.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# Msg3's should calculate the page ranges fast
#Msg3.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# fast parsing
Xml.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
XmlNode.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Words.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Unicode.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
UCWordIterator.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
UCPropTable.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
UnicodeProperties.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
UCNormalizer.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Pos.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Pops.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Bits.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Scores.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Sections.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Weights.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
neighborhood.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
TermTable.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
#Summary.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 
Title.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

# fast relate topics generation
Msg24.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Msg1a.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Msg1b.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

SafeBuf.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

Msg1c.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -c $*.cpp 

Msg1d.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -c $*.cpp 

AutoBan.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

Profiler.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

HtmlCarver.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

HashTableT.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

Timedb.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

HashTableX.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

SpiderCache.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

DateParse.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

#DateParse2.o:
#	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

test_parser2.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O2 -c $*.cpp 

Language.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

WordsWindow.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

AppendingWordsWindow.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

PostQueryRerank.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O2 -c $*.cpp 

sort.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -O3 -c $*.cpp 

# SiteBonus.o:
# 	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O3 -c $*.cpp 
Msg6a.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS)  -O3 -c $*.cpp 

# Stupid gcc-2.95 stabs debug can't handle such a big file.
geo_ip_table.o: geo_ip_table.cpp geo_ip_table.h
	$(CC) $(DEFS) $(DEFS2) -m32 -Wall -pipe -c $*.cpp 

# move this tarball into ~/rpmbuild/?????
# then run rpmbuild -ba gb-1.0.spec to build the rpms
# rpm -ivh gb-1.0-...  to install the pkg
tarball-testing:
#	git archive --format=tar master | gzip > gb.tar
	git archive --format=tar --prefix=gb-1.0/ testing > gb-1.0.tar

master-rpm:
#	git archive --format=tar master | gzip > gb.tar
	git archive --format=tar --prefix=gb-1.0/ master > gb-1.0.tar
	mv gb-1.0.tar /home/mwells/rpmbuild/SOURCES/
	rpmbuild -ba gb-1.0.spec
	scp /home/mwells/rpmbuild/RPMS/x86_64/gb-*rpm www.gigablast.com:/w/html/

# dpkg-buildpackage calls 'make binary' to create the files for the deb pkg
# which must all be stored in ./debian/gb/

install:
# gigablast will copy over the necessary files. it has a list of the
# necessary files and that list changes over time so it is better to let gb
# deal with it.
	mkdir -p $(DESTDIR)/var/gigablast/data0/
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/init.d/
	mkdir -p $(DESTDIR)/etc/init/
	mkdir -p $(DESTDIR)/lib/init/
	./gb copyfiles $(DESTDIR)/var/gigablast/data0/
# if user types 'gb' it will use the binary in /var/gigablast/data0/gb
	rm -f $(DESTDIR)/usr/bin/gb
	ln -s /var/gigablast/data0/gb $(DESTDIR)/usr/bin/gb
# if machine restarts...
# the new way that does not use run-levels anymore
	rm -f $(DESTDIR)/etc/init.d/gb
	ln -s /lib/init/upstart-job $(DESTDIR)/etc/init.d/gb
# initctl upstart-job conf file (gb stop|start|reload)
	cp init.gb.conf $(DESTDIR)/etc/init/gb.conf

.cpp.o:
	$(CC) $(DEFS) $(DEFS2) $(CPPFLAGS) -c $*.cpp 

#.cpp: $(OBJS)
#	$(CC) $(DEFS) $(CPPFLAGS) -o $@ $@.o $(OBJS) $(LIBS)
#	$(CC) $(DEFS) $(CPPFLAGS) -o $@ $@.cpp $(OBJS) $(LIBS)

##
## Auto dependency generation
## This is broken, if you edit Version.h and recompile it doesn't work. (mdw)
#%.d: %.cpp	
#	@echo "generating dependency information for $<"
#	@set -e; $(CC) -M $(DEFS) $(CPPFLAGS) $< \
#	| sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
#	[ -s $@ ] || rm -f $@
#-include $(SRCS:.cpp=.d)

depend: 
	@echo "generating dependency information"
	( $(CC) -MM $(DEFS) $(DPPFLAGS) *.cpp > Make.depend ) || \
	$(CC) -MM $(DEFS) $(DPPFLAGS) *.cpp > Make.depend 

-include Make.depend

# DEBIAN PACKAGE SECTION BEGIN

testing-deb:
	git archive --format=tar --prefix=gb-1.0/ testing > ../gb_1.0.orig.tar
# change "-p gb_1.0" to "-p gb_1.1" to update version for example
	dh_make -e gigablast@mail.com -p gb_1.0 -f ../gb_1.0.orig.tar
# zero this out, it is just filed with the .txt files erroneously
	rm debian/docs
	touch debian/docs
# fix dh_shlibdeps from bitching about dependencies on shared libs
	export LD_LIBRARY_PATH=./debian/gb/var/gigablast/data0
# build the package now
# turn on the debug flag in debian/rules to debug this (export DH_VERBOSE=1)
	dpkg-buildpackage -b -uc -rfakeroot

# DEBIAN PACKAGE SECTION END
