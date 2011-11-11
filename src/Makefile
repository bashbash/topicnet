#=========================================================================
# Topicnet Makefile
#=========================================================================

include Makefile.config
SRCDIR = .

SRCS = 	$(SRCDIR)/FR_Layout.cpp\
	    $(SRCDIR)/graph.cpp\
	    $(SRCDIR)/graphEdge.cpp\
	    $(SRCDIR)/graphNode.cpp\
	    $(SRCDIR)/grid.cpp\
	    $(SRCDIR)/gridNode.cpp\
	    $(SRCDIR)/lua_topnet.cpp\
	    $(SRCDIR)/topnet.cpp\
	    $(SRCDIR)/topnet_udata.cpp\
	    $(SRCDIR)/tinyxml.cpp\
	    $(SRCDIR)/tinystr.cpp\
	    $(SRCDIR)/tinyxmlerror.cpp\
	    $(SRCDIR)/tinyxmlparser.cpp
	

OBJS = $(SRCS:.cpp=.o)

.cpp.o:
	@echo CC $<
	@$(CC) -c $(CFLAGS) $< -o $*.o
	
$(SLIB_FILE): $(OBJS)
	@echo SH $@
	@$(CC) $(SLIBFLAGS) $(CFLAGS) $(LFLAGS) -o $@ $(OBJS)

clean:
	@rm -f $(SRCDIR)/*.o *.$(SLIB_EXT)
	@rm -f $(SRCDIRX)/*.o *.$(SLIB_EXT)

all: $(SLIB_FILE) 

