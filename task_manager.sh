#!/usr/bin/env bash

# Initialize tasks.txt if not already existing
[[ ! -f tasks.txt ]] && touch tasks.txt

# ─── ANSI Color Codes ───────────────────────────────────────────────────────
R=$'\033[0;31m'    # Red
G=$'\033[0;32m'    # Green
Y=$'\033[1;33m'    # Yellow
B=$'\033[0;34m'    # Blue
C=$'\033[0;36m'    # Cyan
BD=$'\033[1m'      # Bold
NC=$'\033[0m'      # Reset

# ─── Print header ────────────────────────────────────────────────────────────
print_header() {
    echo ""
    echo "${BD}${C}╔══════════════════════════════════════╗${NC}"
    echo "${BD}${C}║        📋  TASK MANAGER CLI          ║${NC}"
    echo "${BD}${C}╚══════════════════════════════════════╝${NC}"
    echo ""
}

# ─── Pretty-print pipe-delimited task rows ───────────────────────────────────
color_task_row() {
    while IFS='|' read -r id title priority due_date status; do
        case "$priority" in
            high)   pri_c="${R}${BD}" ;;
            medium) pri_c="${Y}" ;;
            low)    pri_c="${G}" ;;
            *)      pri_c="${NC}" ;;
        esac
        case "$status" in
            done)        st_c="${G}" ;;
            in-progress) st_c="${Y}" ;;
            pending)     st_c="${C}" ;;
            *)           st_c="${NC}" ;;
        esac
        printf "${BD}[%s]${NC} %-30s  Priority: %s%-8s${NC}  Due: ${B}%s${NC}  Status: %s%s${NC}\n" \
            "$id" "$title" "$pri_c" "$priority" "$due_date" "$st_c" "$status"
    done
}

# ─── Add a task ──────────────────────────────────────────────────────────────
add_task() {
    echo "${BD}${C}── Add New Task ──────────────────────────${NC}"

    printf "${Y}Enter Task Title: ${NC}"
    read title
    if [[ -z "$title" ]]; then
        echo "${R}✗ Title cannot be empty.${NC}"; return
    fi

    printf "${Y}Enter Priority (high/medium/low): ${NC}"
    read priority
    if [[ ! "$priority" =~ ^(high|medium|low)$ ]]; then
        echo "${R}✗ Invalid priority. Must be high, medium, or low.${NC}"; return
    fi

    printf "${Y}Enter Due Date (YYYY-MM-DD): ${NC}"
    read due_date
    if [[ ! "$due_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "${R}✗ Invalid date format. Use YYYY-MM-DD.${NC}"; return
    fi

    last_id=$(awk -F'|' 'NF{print $1}' tasks.txt | sort -n | tail -n 1)
    new_id=$(( ${last_id:-0} + 1 ))
    echo "$new_id|$title|$priority|$due_date|pending" >> tasks.txt
    echo "${G}✓ Task #$new_id added successfully.${NC}"
}

# ─── List tasks ──────────────────────────────────────────────────────────────
list_tasks() {
    echo "${BD}${C}── List Tasks ────────────────────────────${NC}"
    echo "${Y}Filter: (1) All  (2) By Status  (3) By Priority  (4) Sort${NC}"
    printf "${Y}Choice: ${NC}"; read filter_choice

    case $filter_choice in
        1)
            if [[ ! -s tasks.txt ]]; then echo "${Y}No tasks found.${NC}"; return; fi
            color_task_row < tasks.txt
            ;;
        2)
            printf "${Y}Status (pending/in-progress/done): ${NC}"; read status
            result=$(awk -F'|' -v s="$status" '$5==s' tasks.txt)
            [[ -z "$result" ]] && { echo "${Y}No tasks with status '$status'.${NC}"; return; }
            echo "$result" | color_task_row
            ;;
        3)
            printf "${Y}Priority (high/medium/low): ${NC}"; read priority
            result=$(awk -F'|' -v p="$priority" '$3==p' tasks.txt)
            [[ -z "$result" ]] && { echo "${Y}No tasks with priority '$priority'.${NC}"; return; }
            echo "$result" | color_task_row
            ;;
        4)
            echo "${Y}Sort by: (1) Priority  (2) Due Date${NC}"
            printf "${Y}Choice: ${NC}"; read sort_choice
            case $sort_choice in
                1) sort_by_priority ;;
                2) sort_by_due_date ;;
                *) echo "${R}✗ Invalid choice.${NC}" ;;
            esac
            ;;
        *) echo "${R}✗ Invalid choice.${NC}" ;;
    esac
}

# ─── Update a task (FIXED) ───────────────────────────────────────────────────
update_task() {
    echo "${BD}${C}── Update Task ───────────────────────────${NC}"
    printf "${Y}Enter Task ID to update: ${NC}"; read task_id

    task_line=$(grep "^${task_id}|" tasks.txt)
    if [[ -z "$task_line" ]]; then
        echo "${R}✗ Task ID $task_id not found.${NC}"; return
    fi

    echo "${B}Current task:${NC}"
    echo "$task_line" | color_task_row

    echo "${Y}Field: (1) Title  (2) Priority  (3) Due Date  (4) Status${NC}"
    printf "${Y}Choice: ${NC}"; read field_choice

    IFS='|' read -r _id _title _priority _due _status <<< "$task_line"

    case $field_choice in
        1)
            printf "${Y}New Title: ${NC}"; read new_val
            [[ -z "$new_val" ]] && { echo "${R}✗ Title cannot be empty.${NC}"; return; }
            _title="$new_val"
            ;;
        2)
            printf "${Y}New Priority (high/medium/low): ${NC}"; read new_val
            [[ ! "$new_val" =~ ^(high|medium|low)$ ]] && { echo "${R}✗ Invalid priority.${NC}"; return; }
            _priority="$new_val"
            ;;
        3)
            printf "${Y}New Due Date (YYYY-MM-DD): ${NC}"; read new_val
            [[ ! "$new_val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && { echo "${R}✗ Invalid date format.${NC}"; return; }
            _due="$new_val"
            ;;
        4)
            printf "${Y}New Status (pending/in-progress/done): ${NC}"; read new_val
            [[ ! "$new_val" =~ ^(pending|in-progress|done)$ ]] && { echo "${R}✗ Invalid status.${NC}"; return; }
            _status="$new_val"
            ;;
        *)
            echo "${R}✗ Invalid option.${NC}"; return
            ;;
    esac

    # Safe update using awk — no sed regex issues with pipe characters
    new_line="${task_id}|${_title}|${_priority}|${_due}|${_status}"
    tmp=$(mktemp)
    awk -v id="$task_id" -v newline="$new_line" -F'|' \
        '$1==id{print newline; next} {print}' tasks.txt > "$tmp" && mv "$tmp" tasks.txt

    echo "${G}✓ Task #$task_id updated successfully.${NC}"
}

# ─── Delete a task ───────────────────────────────────────────────────────────
delete_task() {
    echo "${BD}${C}── Delete Task ───────────────────────────${NC}"
    printf "${Y}Enter Task ID to delete: ${NC}"; read task_id

    task_line=$(grep "^${task_id}|" tasks.txt)
    if [[ -z "$task_line" ]]; then
        echo "${R}✗ Task ID $task_id not found.${NC}"; return
    fi

    echo "${B}Task to delete:${NC}"
    echo "$task_line" | color_task_row

    printf "${R}Are you sure? (y/n): ${NC}"; read confirmation
    if [[ "$confirmation" == "y" ]]; then
        sed -i "/^${task_id}|/d" tasks.txt
        echo "${G}✓ Task #$task_id deleted.${NC}"
    else
        echo "${Y}Deletion cancelled.${NC}"
    fi
}

# ─── Search tasks ────────────────────────────────────────────────────────────
search_task() {
    echo "${BD}${C}── Search Tasks ──────────────────────────${NC}"
    printf "${Y}Enter regex to search: ${NC}"; read regex
    result=$(grep -i "$regex" tasks.txt)
    if [[ -z "$result" ]]; then
        echo "${Y}No matching tasks found.${NC}"
    else
        echo "$result" | color_task_row
    fi
}

# ─── Task summary ────────────────────────────────────────────────────────────
task_summary() {
    echo "${BD}${C}── Task Summary ──────────────────────────${NC}"
    pending_count=$(grep -c "|pending$" tasks.txt 2>/dev/null || true)
    in_progress_count=$(grep -c "|in-progress$" tasks.txt 2>/dev/null || true)
    done_count=$(grep -c "|done$" tasks.txt 2>/dev/null || true)
    pending_count=${pending_count:-0}
    in_progress_count=${in_progress_count:-0}
    done_count=${done_count:-0}
    total=$(( pending_count + in_progress_count + done_count ))

    echo ""
    printf "  ${C}Pending    : ${R}${BD}%s${NC}\n" "$pending_count"
    printf "  ${C}In-Progress: ${Y}%s${NC}\n" "$in_progress_count"
    printf "  ${C}Done       : ${G}%s${NC}\n" "$done_count"
    printf "  ${C}─────────────────${NC}\n"
    printf "  ${C}Total      : ${BD}%s${NC}\n" "$total"
    echo ""
}

# ─── Overdue tasks ───────────────────────────────────────────────────────────
overdue_tasks() {
    echo "${BD}${C}── Overdue Tasks ─────────────────────────${NC}"
    today=$(date +%Y-%m-%d)
    result=$(awk -F'|' -v today="$today" '$4 < today && $5 != "done"' tasks.txt)
    if [[ -z "$result" ]]; then
        echo "${G}✓ No overdue tasks!${NC}"
    else
        echo "${R}${BD}The following tasks are overdue:${NC}"
        echo "$result" | color_task_row
    fi
}

# ─── Priority report ─────────────────────────────────────────────────────────
priority_report() {
    echo "${BD}${C}── Priority Report ───────────────────────${NC}"
    for level in high medium low; do
        case $level in
            high)   echo "${R}${BD}▶ High Priority:${NC}" ;;
            medium) echo "${Y}${BD}▶ Medium Priority:${NC}" ;;
            low)    echo "${G}${BD}▶ Low Priority:${NC}" ;;
        esac
        result=$(awk -F'|' -v p="$level" '$3==p' tasks.txt)
        if [[ -z "$result" ]]; then echo "  (none)"; else echo "$result" | color_task_row; fi
        echo ""
    done
}

# ─── Export to CSV ───────────────────────────────────────────────────────────
export_to_csv() {
    echo "${BD}${C}── Export to CSV ─────────────────────────${NC}"
    { echo "ID,Title,Priority,Due Date,Status"
      awk -F'|' 'BEGIN{OFS=","} {print $1,$2,$3,$4,$5}' tasks.txt
    } > tasks.csv
    echo "${G}✓ Tasks exported to tasks.csv${NC}"
}

# ─── Sort functions ──────────────────────────────────────────────────────────
sort_by_priority() {
    echo "${BD}${C}── Sorted by Priority ────────────────────${NC}"
    awk -F'|' 'BEGIN{rank["high"]=1;rank["medium"]=2;rank["low"]=3}
               {print rank[$3] "|" $0}' tasks.txt \
    | sort -t'|' -k1,1n \
    | cut -d'|' -f2- \
    | color_task_row
}

sort_by_due_date() {
    echo "${BD}${C}── Sorted by Due Date ────────────────────${NC}"
    sort -t'|' -k4,4 tasks.txt | color_task_row
}

# ─── Main Menu ───────────────────────────────────────────────────────────────
main_menu() {
    print_header
    PS3="${BD}${C}▶ Select an option: ${NC}"
    select option in \
        "Add Task" \
        "List Tasks" \
        "Update Task" \
        "Delete Task" \
        "Search Task" \
        "Task Summary" \
        "Overdue Tasks" \
        "Priority Report" \
        "Export Tasks to CSV" \
        "Sort Tasks" \
        "Exit"
    do
        echo ""
        case $option in
            "Add Task")             add_task ;;
            "List Tasks")           list_tasks ;;
            "Update Task")          update_task ;;
            "Delete Task")          delete_task ;;
            "Search Task")          search_task ;;
            "Task Summary")         task_summary ;;
            "Overdue Tasks")        overdue_tasks ;;
            "Priority Report")      priority_report ;;
            "Export Tasks to CSV")  export_to_csv ;;
            "Sort Tasks")
                echo "${Y}Sort by: (1) Priority  (2) Due Date${NC}"
                printf "${Y}Choice: ${NC}"; read sort_choice
                case $sort_choice in
                    1) sort_by_priority ;;
                    2) sort_by_due_date ;;
                    *) echo "${R}✗ Invalid choice.${NC}" ;;
                esac
                ;;
            "Exit")
                echo "${G}${BD}Goodbye! 👋${NC}"; echo ""; break ;;
            *)
                echo "${R}✗ Invalid option. Try again.${NC}" ;;
        esac
        echo ""
    done
}

main_menu
