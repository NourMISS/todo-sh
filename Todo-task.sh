#!/bin/bash

# Function to create a task
add_task() {
    echo "Creating a new task..."
    read -rp "Enter the title: " title
    title=$(echo "$title" | tr -dc '[:alnum:][:space:]')
    if [[ -z "$title" ]]; then
        echo "Title is required." >&2
        return
    fi

    read -rp "Enter the due date (YYYY-MM-DD): " due_date
    if ! [[ "$due_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Invalid due date format. Please use YYYY-MM-DD." >&2
        return
    fi

    read -rp "Enter the description: " description
    description=$(echo "$description" | tr -dc '[:alnum:][:space:]')
    read -rp "Enter the location: " location
    location=$(echo "$location" | tr -dc '[:alnum:][:space:]')
    read -rp "Enter the priority (high/medium/low): " priority
    if [[ -z "$priority" ]]; then
        echo "Priority is required." >&2
        return
    fi

    read -rp "Is the task completed? (yes/no): " completion
    if [[ "$completion" == "yes" ]]; then
        completion=true
    else
        completion=false
    fi

    echo "$title,$due_date,$description,$location,$priority,$completion" >> tasks.csv
    echo "Task created successfully."
}

# Function to update a task
update_task() {
    echo "Updating a task..."
    read -rp "Enter the task ID: " task_id
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        echo "Invalid task ID." >&2
        return
    fi

    read -rp "Enter the new title: " title
    title=$(echo "$title" | tr -dc '[:alnum:][:space:]')
    if [[ -z "$title" ]]; then
        echo "Title is required." >&2
        return
    fi

    read -rp "Enter the new due date (YYYY-MM-DD): " due_date
    if ! [[ "$due_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Invalid due date format. Please use YYYY-MM-DD." >&2
        return
    fi

    read -rp "Enter the new description: " description
    description=$(echo "$description" | tr -dc '[:alnum:][:space:]')
    read -rp "Enter the new location: " location
    location=$(echo "$location" | tr -dc '[:alnum:][:space:]')
    read -rp "Enter the new priority (high/medium/low): " priority
    if [[ -z "$priority" ]]; then
        echo "Priority is required." >&2
        return
    fi

    read -rp "Is the task completed? (yes/no): " completion
    if [[ "$completion" == "yes" ]]; then
        completion=true
    else
        completion=false
    fi

    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$title")/1" tasks.csv
    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$due_date")/2" tasks.csv
    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$description")/3" tasks.csv
    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$location")/4" tasks.csv
    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$priority")/5" tasks.csv
    sed -i "${task_id}s/[^,]*/$(sed 's/[&/]/\&/g' <<< "$completion")/6" tasks.csv
    echo "Task updated successfully."
}

# Function to delete a task
delete_task() {
    echo "Deleting a task..."
    read -rp "Enter the task ID: " task_id
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        echo "Invalid task ID." >&2
        return
    fi

    if [[ ! -f "tasks.csv" ]]; then
        echo "Task file not found." >&2
        return
    fi

    sed -i "${task_id}d" tasks.csv
    echo "Task deleted successfully."
}

# Function to list all tasks
list_tasks() {
    echo "Listing all tasks..."
    awk -F, 'BEGIN { printf "%-8s %-20s %-12s %-30s %-20s %-10s %-10s
", "Task ID", "Title", "Due Date", "Description", "Location", "Priority", "Completion" } 
    { printf "%-8s %-20s %-12s %-30s %-20s %-10s %-10s
", NR, $1, $2, $3, $4, $5, $6 }' tasks.csv
}

# Function to search for a task
search_task() {
    echo "Searching for a task..."
    read -rp "Enter the search term: " search_term
    awk -F, -v search_term="$search_term" 'BEGIN { printf "%-8s %-20s %-12s %-30s %-20s %-10s %-10s
", "Task ID", "Title", "Due Date", "Description", "Location", "Priority", "Completion" } 
    $1 ~ search_term || $2 ~ search_term || $3 ~ search_term || $4 ~ search_term || $5 ~ search_term || $6 ~ search_term { printf "%-8s %-20s %-12s %-30s %-20s %-10s %-10s
", NR, $1, $2, $3, $4, $5, $6 }' tasks.csv
}

# Function to mark a task as completed
complete_task() {
    echo "Marking a task as completed..."
    read -rp "Enter the task ID: " task_id
    sed -i "${task_id}s/[^,]*$/Completed/" tasks.csv
    echo "Task marked as completed."
}

# Main program loop
while true; do
    echo "1. Add a task"
    echo "2. Update a task"
    echo "3. Delete a task"
    echo "4. List all tasks"
    echo "5. Search for a task"
    echo "6. Mark a task as completed"
    echo "7. Exit"
    read -rp "Enter your choice: " choice
    case "$choice" in
        1) add_task ;;
        2) update_task ;;
        3) delete_task ;;
        4) list_tasks ;;
        5) search_task ;;
        6) complete_task ;;
        7) break ;;
        *) echo "Invalid choice." ;;
    esac
done
