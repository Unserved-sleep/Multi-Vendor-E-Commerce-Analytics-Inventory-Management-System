import random

def weighted_status():

    return random.choices(
        ['delivered','shipped',
         'pending','cancelled'],
        weights=[70,15,10,5]
    )[0]