# Recursive ID3 function
def train(examples)
	return 1 if examples.empty?
	# PART 1
	# if all examples in S are the same class, return a leaf with class label
	unique_class = true
	examples.each do |ex|
		
		if examples.first.last != ex.last
			unique_class = false
			break
		end
	end

	return examples.first.last if unique_class

	# Part 2 
	# If there are no more attributes to test return a leaf with the most common class label

	# Part 3
	# Get attribute with max gain. Add branch for this attribute. Recursive

	# get system entropy
	system_entropy = system_entropy(examples)

	# Get gain for each attribute and keep the att with max gain
	attrubtes_gain = []
	attribute_gain = 0
	winner_att = ""
	@attributes.each do |k,v|
		gain = attribute_gain(k, @attributes[k], examples, system_entropy)
		if gain > attribute_gain
			attribute_gain = gain
			winner_att = k
		end
	end

	best = winner_att # Node.new(winner_att, attribute_gain)
	current_tree = {best => {}}

	# Creating the new set of examples for the each possibility of the max gain attribute above gotten
	new_examples = []
	position_to_search = @attribute_position[best.to_sym] # Getting the index where the attribute is on each example

	@attributes[best.to_sym].each do |value|
		new_examples = []
		examples.each do |ex|
			new_examples << ex if ex[position_to_search] == value
		end 
		# Recursive call
		current_tree[best.to_sym][value.to_sym] = train(new_examples)

	end
	 
	current_tree #returns current tree
end

# Entropy(S)
def system_entropy(examples)
	summation = []
	# Here I get  of each class: (class_total / total) * log((class_total / total))
	# Then I add that calculation for ach class and finally sum up each one to GET ENTROPY of system reciebed in examples param
	@classes.each do |c|
		class_count = (examples.map {|ex| ex.last}).count(c) # get number of samples for the current "c" class
		if class_count == 0 # assumming zero as value to avoid NaN given a Log2(0)
			summation << 0
		else
			summation << (class_count.to_f / examples.count) * Math::log((class_count.to_f / examples.count), 2)
		end
	end
	-(summation.inject(:+)) # sums up and returns calculated system entropy
end

# Gain (S, a)
# attribute: the attribute which we are going to calculate gain
# attribute_values: possible values for this attribute
# examples: examples to calculate gain
def attribute_gain(attribute, attribute_values, examples, system_entropy)

	# Calculate entropy of each value of the attribute
	# 1. Get number of attribute appearances given each class
	class_attr_appearances = {}
	ex_gropued_by_class = examples.group_by{|x| x.last}.values # groups the examples by class value (On each index an array of examples from same class)
	position_to_search = @attribute_position[attribute.to_sym] # Getting the index where the attribute is on each example
	
	gain = system_entropy
	attribute_values.each do |attr_val|	# iterating over each possible attribute value
		attribute_quantities = [] # To Store number of attribute appeareances per attribute value
		summation = []
		ex_gropued_by_class.each do |class_group| # iterating over each group of examples with same class
			count = 0
			class_group.each do |ex| #iterating over each example of the current set of examples with same class
				count +=1 if ex[position_to_search] == attr_val
			end
			attribute_quantities << count			
		end
		attribute_quantities.each do |val|
			if val == 0 # assumming zero as value to avoid NaN given a Log2(0)
				summation << 0
			else
				summation << (val.to_f / attribute_quantities.inject(:+)) * Math::log((val.to_f / attribute_quantities.inject(:+)), 2)
			end
		end
		current_entropy = -(summation.inject(:+)) # sums up and returns calculated attribute value entropy		
		gain -= ((attribute_quantities.inject(:+).to_f / examples.count) * current_entropy.to_f)
	end

	gain # return gain
end


# Initial file reading
file = File.open("cara.data", "r")

count = 0 # to identify structures of datas of the data file
@classes = [] # To store all the classes of the sample data
@attributes = {} # To store all the attributes of the sample data and their possible values: [{attribute: [values]}, {attribute: [values]}, ...]
examples = [] # To store all the examples, one per array position
@attribute_position = {} # to know what the corresponding attribute for each position on a example line
att_count = 0
file.each_line do |line|
	line_values = line.strip.split(",")		
	if line.to_i == 0  # identifying if line is a number. If so, begins a new structure (targest, attributes or examples)
		case count
		when 1 # targets
			@classes = line_values
		when 2 # attributes			
			@attributes[line_values.first.to_sym] = line_values.drop(2)		
			@attribute_position[line_values.first.to_sym] = att_count
			att_count += 1
		when 3 # examples
			examples << line_values
		end
	else
		count += 1
	end
end


@tree = {} #Final tree instantiation
@tree = train(examples) # Calls train with initial set of examples read on the original dataset
print @tree



