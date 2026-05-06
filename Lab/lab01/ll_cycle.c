#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head)
{
    /* your code here */
    node *tortoise = head, *hare = head;
    do
    {
        if (hare == NULL || hare->next == NULL)
            return 0;
        else
            hare = hare->next->next;
        tortoise = tortoise->next;
    } while (hare != tortoise);
    return 1;
}