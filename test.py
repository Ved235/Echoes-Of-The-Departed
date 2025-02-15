import sys
import time

def find_node_end(lines, start_index):
    indent = len(lines[start_index]) - len(lines[start_index].lstrip())
    i = start_index + 1
    
    while i < len(lines):
        if len(lines[i].strip()) == 0:
            i += 1
            continue
        current_indent = len(lines[i]) - len(lines[i].lstrip())
        if current_indent <= indent:
            return i - 1
        i += 1
    return len(lines) - 1

def process_scene_file(input_file, output_file):
    print(f"Reading file: {input_file}")
    
    try:
        with open(input_file, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading file: {e}")
        return False

    print(f"Processing {len(lines)} lines...")
    modified_lines = []
    i = 0
    nodes_processed = 0
    
    while i < len(lines):
        line = lines[i]
        modified_lines.append(line)
        
        # Check if this is a Node3D line
        if 'Node3D' in line and 'type="Node3D"' in line:
            nodes_processed += 1
            if nodes_processed % 10 == 0:
                print(f"Processed {nodes_processed} nodes...")
            
            # Get the indentation level
            indent = len(line) - len(line.lstrip())
            
            # Add collision components with proper indentation
            collision_lines = [
                " " * (indent + 2) + '[node name="StaticBody3D" type="StaticBody3D" parent="."]\n',
                " " * (indent + 4) + '[node name="CollisionShape3D" type="CollisionShape3D" parent="."]\n',
                " " * (indent + 6) + '[shape type="ConvexPolygonShape3D" id="ConvexPolygonShape3D_x1y2z"]\n'
            ]
            modified_lines.extend(collision_lines)
        
        i += 1
        
        # Safety check to prevent infinite loops
        if i > len(lines) * 2:
            print("Error: Processing loop exceeded maximum iterations")
            return False

    print(f"Total nodes processed: {nodes_processed}")
    print(f"Writing modified scene to: {output_file}")
    
    try:
        with open(output_file, 'w') as f:
            f.writelines(modified_lines)
    except Exception as e:
        print(f"Error writing file: {e}")
        return False

    print("Scene modification completed successfully!")
    return True

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python scene_modifier.py input_scene.tscn output_scene.tscn")
        sys.exit(1)
    
    start_time = time.time()
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    success = process_scene_file(input_file, output_file)
    
    end_time = time.time()
    print(f"Total execution time: {end_time - start_time:.2f} seconds")
    
    if not success:
        sys.exit(1)