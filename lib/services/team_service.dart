import 'dart:async';
import '../models/models.dart';

class TeamService {
  // Mock team data for fashion store
  static final List<TeamMember> _teamMembers = [
    // Executive Team
    TeamMember(
      id: 'team_001',
      name: 'Sarah Johnson',
      role: 'CEO & Founder',
      department: 'Executive',
      bio: 'Visionary leader with 15+ years in fashion industry. Passionate about sustainable fashion and customer experience.',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b332c1c5?w=400',
      email: 'sarah.johnson@fashionstore.com',
      phone: '+1 (555) 123-4567',
      socialLinks: [
        'https://linkedin.com/in/sarahjohnson',
        'https://twitter.com/sarahjohnson',
        'https://instagram.com/sarahjohnson',
      ],
      experience: 15,
      skills: ['Leadership', 'Strategy', 'Fashion Design', 'Business Development'],
      isFeatured: true,
      joinDate: DateTime.parse('2018-01-15'),
    ),
    TeamMember(
      id: 'team_002',
      name: 'Michael Chen',
      role: 'Creative Director',
      department: 'Design',
      bio: 'Award-winning designer with expertise in trend forecasting and brand development. International fashion week veteran.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      email: 'michael.chen@fashionstore.com',
      phone: '+1 (555) 123-4568',
      socialLinks: [
        'https://linkedin.com/in/michaelchen',
        'https://instagram.com/michaelchen',
      ],
      experience: 12,
      skills: ['Creative Direction', 'Trend Forecasting', 'Brand Development', 'Visual Design'],
      isFeatured: true,
      joinDate: DateTime.parse('2019-03-20'),
    ),
    TeamMember(
      id: 'team_003',
      name: 'Emily Rodriguez',
      role: 'Operations Manager',
      department: 'Operations',
      bio: 'Expert in supply chain management and retail operations. Ensures smooth day-to-day operations and customer satisfaction.',
      imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
      email: 'emily.rodriguez@fashionstore.com',
      phone: '+1 (555) 123-4569',
      socialLinks: [
        'https://linkedin.com/in/emilyrodriguez',
      ],
      experience: 8,
      skills: ['Operations Management', 'Supply Chain', 'Customer Service', 'Process Optimization'],
      isFeatured: false,
      joinDate: DateTime.parse('2020-06-10'),
    ),

    // Design Team
    TeamMember(
      id: 'team_004',
      name: 'Jessica Taylor',
      role: 'Senior Fashion Designer',
      department: 'Design',
      bio: 'Specializes in women\'s contemporary wear. Graduate of Parsons School of Design with multiple fashion awards.',
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      email: 'jessica.taylor@fashionstore.com',
      phone: '+1 (555) 123-4570',
      socialLinks: [
        'https://instagram.com/jessicataylor',
        'https://pinterest.com/jessicataylor',
      ],
      experience: 7,
      skills: ['Fashion Design', 'Pattern Making', 'Textile Knowledge', 'Trend Analysis'],
      isFeatured: true,
      joinDate: DateTime.parse('2021-02-15'),
    ),
    TeamMember(
      id: 'team_005',
      name: 'David Kim',
      role: 'UX/UI Designer',
      department: 'Design',
      bio: 'Creates beautiful digital experiences for our online store. Expert in user-centered design and e-commerce optimization.',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
      email: 'david.kim@fashionstore.com',
      phone: '+1 (555) 123-4571',
      socialLinks: [
        'https://dribbble.com/davidkim',
        'https://behance.net/davidkim',
      ],
      experience: 5,
      skills: ['UI Design', 'UX Research', 'Prototyping', 'Design Systems'],
      isFeatured: false,
      joinDate: DateTime.parse('2021-09-01'),
    ),

    // Marketing Team
    TeamMember(
      id: 'team_006',
      name: 'Amanda Foster',
      role: 'Marketing Director',
      department: 'Marketing',
      bio: 'Digital marketing expert with proven success in fashion e-commerce. Data-driven approach to brand growth.',
      imageUrl: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400',
      email: 'amanda.foster@fashionstore.com',
      phone: '+1 (555) 123-4572',
      socialLinks: [
        'https://linkedin.com/in/amandafoster',
        'https://twitter.com/amandafoster',
      ],
      experience: 10,
      skills: ['Digital Marketing', 'Brand Strategy', 'Analytics', 'Content Marketing'],
      isFeatured: true,
      joinDate: DateTime.parse('2019-11-12'),
    ),
    TeamMember(
      id: 'team_007',
      name: 'Ryan Martinez',
      role: 'Social Media Manager',
      department: 'Marketing',
      bio: 'Creative storyteller with expertise in fashion social media. Builds engaging communities across all platforms.',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      email: 'ryan.martinez@fashionstore.com',
      phone: '+1 (555) 123-4573',
      socialLinks: [
        'https://instagram.com/ryanmartinez',
        'https://tiktok.com/@ryanmartinez',
      ],
      experience: 4,
      skills: ['Social Media Strategy', 'Content Creation', 'Community Management', 'Influencer Marketing'],
      isFeatured: false,
      joinDate: DateTime.parse('2022-01-10'),
    ),

    // Customer Service Team
    TeamMember(
      id: 'team_008',
      name: 'Lisa Wang',
      role: 'Customer Service Lead',
      department: 'Customer Service',
      bio: 'Dedicated to providing exceptional customer experiences. Expert in conflict resolution and customer satisfaction.',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      email: 'lisa.wang@fashionstore.com',
      phone: '+1 (555) 123-4574',
      socialLinks: [
        'https://linkedin.com/in/lisawang',
      ],
      experience: 6,
      skills: ['Customer Service', 'Communication', 'Problem Solving', 'Team Leadership'],
      isFeatured: false,
      joinDate: DateTime.parse('2020-08-15'),
    ),
    TeamMember(
      id: 'team_009',
      name: 'James Wilson',
      role: 'Store Manager',
      department: 'Retail',
      bio: 'Experienced retail manager with deep knowledge of fashion merchandising and team leadership.',
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400',
      email: 'james.wilson@fashionstore.com',
      phone: '+1 (555) 123-4575',
      socialLinks: [
        'https://linkedin.com/in/jameswilson',
      ],
      experience: 9,
      skills: ['Retail Management', 'Merchandising', 'Sales Strategy', 'Team Management'],
      isFeatured: false,
      joinDate: DateTime.parse('2019-05-20'),
    ),
  ];

  // ── Get All Team Members ───────────────────────────────────
  Stream<List<TeamMember>> getAllTeamMembers() {
    return Stream.value(_teamMembers).asyncMap(
      (members) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return members;
      },
    );
  }

  // ── Get Featured Team Members ───────────────────────────────
  Stream<List<TeamMember>> getFeaturedTeamMembers() {
    return Stream.value(_teamMembers.where((member) => member.isFeatured).toList()).asyncMap(
      (members) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return members;
      },
    );
  }

  // ── Get Team Members by Department ───────────────────────────
  Stream<List<TeamMember>> getTeamMembersByDepartment(String department) {
    return Stream.value(_teamMembers.where((member) => member.department == department).toList()).asyncMap(
      (members) async {
        await Future.delayed(const Duration(milliseconds: 400));
        return members;
      },
    );
  }

  // ── Get All Departments ─────────────────────────────────────
  List<String> getAllDepartments() {
    final departments = _teamMembers.map((member) => member.department).toSet().toList();
    departments.sort();
    return departments;
  }

  // ── Get Team Member by ID ───────────────────────────────────
  Future<TeamMember?> getTeamMemberById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _teamMembers.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  // ── Search Team Members ─────────────────────────────────────
  Stream<List<TeamMember>> searchTeamMembers(String query) {
    final filtered = _teamMembers.where((member) =>
        member.name.toLowerCase().contains(query.toLowerCase()) ||
        member.role.toLowerCase().contains(query.toLowerCase()) ||
        member.department.toLowerCase().contains(query.toLowerCase()) ||
        member.bio.toLowerCase().contains(query.toLowerCase())).toList();
    
    return Stream.value(filtered).asyncMap(
      (members) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return members;
      },
    );
  }

  // ── Get Department Statistics ───────────────────────────────
  Map<String, int> getDepartmentStatistics() {
    final stats = <String, int>{};
    for (final member in _teamMembers) {
      stats[member.department] = (stats[member.department] ?? 0) + 1;
    }
    return stats;
  }

  // ── Get Total Team Size ────────────────────────────────────
  int get totalTeamSize => _teamMembers.length;

  // ── Get Featured Team Size ──────────────────────────────────
  int get featuredTeamSize => _teamMembers.where((member) => member.isFeatured).length;
}
