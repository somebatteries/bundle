import re
def get_cols( text, flags='ignore_comments' ):
    word = "(?P<word>\S+)"
    cols = []
    for line_match in re.finditer( ".*", text ):
        line = line_match.group( 0 ) 
        for m in re.finditer( word, line ):
            cols.append( { 'text':m.group('word'), 'col':m.start('word') })

        if( 'ignore_comments' in flags ):
            to_remove = []
            comment_cols = get_comment_cols( line )
            for [ comment_start, comment_end ] in comment_cols:
                for col in cols:
                    if( comment_start <= col[ 'col' ] and col[ 'col' ] <= comment_end ):
                        to_remove.append( col )
            for item in to_remove: 
                cols.remove( item )

    return cols

def get_comment_cols( text ):
    comment_cols = []
    comment = "(?P<comment>\/\* *.*? *\*\/)"
    for m in re.finditer( comment, text ):
        comment_cols.append( [ m.start('comment'), m.end('comment') ] )
    return comment_cols


def k_means( data, k ):
    group = []
    group_prev = []
    centroid = []
    sigma = []
    N = []

    #-------------------------------------------------------
    # Initialize variables
    #-------------------------------------------------------
    for i in range( len( data ) ):
        group.append( -1 )
        group_prev.append( -1 )
    for i in range( k ):
        centroid.append( 0 )
        sigma.append( 0 )
        N.append( 0 )

    #-------------------------------------------------------
    # Assign the initial centroids and groups
    #-------------------------------------------------------
    unique_data = []
    unique_data_idx = []
    for i in range( len( data ) ):
        if( data[ i ] not in unique_data ):
            unique_data_idx.append( i )
            unique_data.append( data[ i ] )

    if( len( unique_data ) < k ):
        k = len( unique_data )

    for i in range( k ):
        group[ unique_data_idx[ i ] ] = i

    converged = False
    while( not converged ):
        #---------------------------------------------------
        # compute centroids for each group
        #---------------------------------------------------
        for i in range( k ):
            sigma[ i ] = 0
            N[ i ] = 0
        for i in range( len( data ) ):
            if( group[ i ] != -1 ):
                sigma[ group[ i ] ] = sigma[ group[ i ] ] + data[ i ]
                N[ group[ i ] ] = N[ group[ i ] ] + 1
        for i in range( k ):
            centroid[ i ] = sigma[ i ] / N[ i ]

        #---------------------------------------------------
        # Assign groups based upon minimum distance to a centroid.
        # If no re-assignments are made, then it has converged
        #---------------------------------------------------
        converged = True
        for i in range( len( data ) ):
            for g in range( 0, k ):
                this_dist = abs( data[ i ] - centroid[ g ] )
                if( ( g == 0 ) or ( this_dist < min_dist ) ):
                    min_dist = this_dist
                    if( ( group[ i ] == -1 ) or ( group[ i ] != g ) ):
                        group[ i ] = g
        if( group != group_prev ):
            converged = False
            group_prev = group
            

    return group

def assign_cols( text ):
    col_dict_list= get_cols( text )
    cols = []
    for col_dict in col_dict_list:
        cols.append( col_dict[ 'col' ] )

    groups = k_means( cols, k )
    for i in range( len( cols ) ):
        col_dict_list[i][ 'group' ] = groups[ i ]

    group_col = []
    for g in range( k ):
        group_col.append( 0 )

    for g in range( k ):
        #---------------------------------------------------
        # Count up how many occurences for each column appear the group
        #---------------------------------------------------
        unique_item_counts = {}
        for i in range( len( cols ) ):
            if( groups[ i ] == g ):
                if( cols[ i ] not in unique_item_counts ):
                    unique_item_counts[ cols[ i ] ] = 1
                else:
                    unique_item_counts[ cols[ i ] ] = unique_item_counts[ cols[ i ] ] + 1

        #---------------------------------------------------
        # Assign a column to this group by using the
        # statistical mode
        #---------------------------------------------------
        first_elem = True
        for [ col, count ] in unique_item_counts.iteritems():
            if( first_elem ):
                group_col[ g ] = int( col )
                first_elem = False
            else:
                if( count > unique_item_counts[ group_col[ g ] ] ):
                    group_col[ g ] = int( col )
        
    #-------------------------------------------------------
    # For each group, set the column to the assigned column
    #-------------------------------------------------------
    for i in range( len( cols ) ):
        col_dict_list[i][ 'col' ] = group_col[ col_dict_list[i][ 'group' ] ]

    print col_dict_list

    returncol_dict_list 

if __name__ == '__main__':
    k = 2;
    text =  "    a_column        another_col  whoops_another_word\n"
    text += "    okay           here\n"
    text += "    okay            here_again\n"
    print assign_cols( text )

