require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'

# Pagy::DEFAULT[:items] = 25
# Pagy::DEFAULT[:size]  = [1,4,4,1]

# Better user experience handling of page links
Pagy::DEFAULT[:overflow] = :last_page
