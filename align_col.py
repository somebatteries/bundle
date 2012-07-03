from optparse import OptionParser
import re
import grm_format as grm

def check_options():
    """Check for command line options"""
    parser = OptionParser(usage="%prog [OPTION] [STRING]\n\nOverview: Formats a selection of text to be printed in vim", version="%prog 0.01")
    parser.add_option("-f", "", type="str", default=None,\
                        dest="fin", help="file with text to be formatted " )

    parser.add_option("-k", "", type="int", default=None,\
                        dest="k", help="Number of columns ( default is auto )" )
    return parser.parse_args()
    
if __name__ == '__main__':
    check_options()
    #check for command line options, if none are passed in, then it runs the gui
    (options, args) = check_options() 

    text = open( options.fin ).read()
    print( grm.align_cols( text, options.k ) )            

